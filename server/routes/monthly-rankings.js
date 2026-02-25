import express from 'express';
const router = express.Router();

export default function(pool, auth) {

  // 创建表（首次自动）
  const initTables = async () => {
    await pool.query(`
      CREATE TABLE IF NOT EXISTS monthly_rankings (
        id SERIAL PRIMARY KEY,
        month VARCHAR(7) NOT NULL,
        rank_type VARCHAR(20) NOT NULL,
        rank_position INT NOT NULL,
        wallet VARCHAR(100) NOT NULL,
        player_name VARCHAR(100),
        score BIGINT DEFAULT 0,
        reward_roon NUMERIC(18,6) DEFAULT 0,
        reward_stones INT DEFAULT 0,
        claimed BOOLEAN DEFAULT false,
        created_at TIMESTAMP DEFAULT NOW(),
        UNIQUE(month, rank_type, wallet)
      );
      CREATE TABLE IF NOT EXISTS monthly_revenue (
        id SERIAL PRIMARY KEY,
        month VARCHAR(7) NOT NULL UNIQUE,
        total_roon NUMERIC(18,6) DEFAULT 0,
        reward_pool NUMERIC(18,6) DEFAULT 0,
        snapshot_done BOOLEAN DEFAULT false,
        distributed BOOLEAN DEFAULT false,
        created_at TIMESTAMP DEFAULT NOW()
      );
      CREATE TABLE IF NOT EXISTS monthly_spending (
        id SERIAL PRIMARY KEY,
        wallet VARCHAR(100) NOT NULL,
        month VARCHAR(7) NOT NULL,
        total_spent BIGINT DEFAULT 0,
        UNIQUE(wallet, month)
      );
      CREATE TABLE IF NOT EXISTS minigame_scores (
        id SERIAL PRIMARY KEY,
        wallet VARCHAR(100) NOT NULL,
        month VARCHAR(7) NOT NULL,
        total_score BIGINT DEFAULT 0,
        UNIQUE(wallet, month)
      );
    `);
  };
  initTables().catch(e => console.error('[MONTHLY] init tables error:', e.message));

  // 获取当前月份 YYYY-MM
  const getCurrentMonth = () => {
    const d = new Date();
    return d.getFullYear() + '-' + String(d.getMonth() + 1).padStart(2, '0');
  };

  // 记录焰晶消费（其他接口调用）
  router.trackSpending = async (wallet, amount) => {
    const month = getCurrentMonth();
    await pool.query(
      `INSERT INTO monthly_spending (wallet, month, total_spent) VALUES ($1, $2, $3)
       ON CONFLICT (wallet, month) DO UPDATE SET total_spent = monthly_spending.total_spent + $3$3`,
      [wallet, month, amount]
    );
  };

  // 记录小游戏分数
  router.trackMinigameScore = async (wallet, score) => {
    const month = getCurrentMonth();
    await pool.query(
      `INSERT INTO minigame_scores (wallet, month, total_score) VALUES ($1, $2, $3)
       ON CONFLICT (wallet, month) DO UPDATE SET total_score = minigame_scores.total_score + $3$3`,
      [wallet, month, score]
    );
  };

  // 查看当月/历史排行榜
  router.get('/current/:type', auth, async (req, res) => {
    try {
      const { type } = req.params;
      const month = req.query.month || getCurrentMonth();
      const validTypes = ['power', 'pk', 'level', 'spending', 'minigame'];
      if (!validTypes.includes(type)) return res.json({ success: false, message: '无效榜单类型' });

      let rows;
      if (type === 'power') {
        rows = (await pool.query(
          'SELECT wallet, name, combat_power as score, level, realm FROM players ORDER BY combat_power DESC LIMIT 50'
        )).rows;
      } else if (type === 'pk') {
        rows = (await pool.query(
          'SELECT r.wallet, p.name, r.rank_score as score, p.level, p.realm FROM pk_rankings r JOIN players p ON p.wallet = r.wallet ORDER BY r.rank_score DESC LIMIT 50'
        )).rows;
      } else if (type === 'level') {
        rows = (await pool.query(
          'SELECT wallet, name, level as score, realm FROM players ORDER BY level DESC LIMIT 50'
        )).rows;
      } else if (type === 'spending') {
        rows = (await pool.query(
          'SELECT s.wallet, p.name, s.total_spent as score, p.level, p.realm FROM monthly_spending s JOIN players p ON p.wallet = s.wallet WHERE s.month = $1 ORDER BY s.total_spent DESC LIMIT 50',
          [month]
        )).rows;
      } else if (type === 'minigame') {
        rows = (await pool.query(
          'SELECT s.wallet, p.name, s.total_score as score, p.level, p.realm FROM minigame_scores s JOIN players p ON p.wallet = s.wallet WHERE s.month = $1 ORDER BY s.total_score DESC LIMIT 50',
          [month]
        )).rows;
      }

      // 我的排名
      const w = req.wallet;
      let myRank = null;
      if (rows) {
        const idx = rows.findIndex(r => r.wallet === w);
        myRank = idx >= 0 ? { rank: idx + 1, score: rows[idx].score } : null;
      }

      res.json({ success: true, rankings: rows || [], myRank, month });
    } catch (e) {
      console.error('[MONTHLY] get rankings error:', e.message);
      res.json({ success: false, message: e.message });
    }
  });

  // 查看历史月榜（已快照的）
  router.get('/history/:month/:type', auth, async (req, res) => {
    try {
      const { month, type } = req.params;
      const rows = (await pool.query(
        'SELECT wallet, player_name as name, score, rank_position, reward_roon FROM monthly_rankings WHERE month = $1 AND rank_type = $2 ORDER BY rank_position ASC',
        [month, type]
      )).rows;
      const revenue = (await pool.query('SELECT * FROM monthly_revenue WHERE month = $1', [month])).rows[0];
      res.json({ success: true, rankings: rows, revenue });
    } catch (e) {
      res.json({ success: false, message: e.message });
    }
  });

  // 查看可用月份列表
  router.get('/months', auth, async (req, res) => {
    try {
      const rows = (await pool.query(
        'SELECT DISTINCT month, snapshot_done, distributed FROM monthly_revenue ORDER BY month DESC LIMIT 12'
      )).rows;
      res.json({ success: true, months: rows });
    } catch (e) {
      res.json({ success: false, message: e.message });
    }
  });

  // Admin: 设置月度收入
  router.post('/admin/set-revenue', auth, async (req, res) => {
    try {
      const w = req.wallet;
      if (w !== '0xfad7eb0814b6838b05191a07fb987957d50c4ca9') {
        return res.json({ success: false, message: '无权限' });
      }
      const { month, totalRoon } = req.body;
      const rewardPool = totalRoon * 0.05;
      await pool.query(
        `INSERT INTO monthly_revenue (month, total_roon, reward_pool) VALUES ($1, $2, $3)
         ON CONFLICT (month) DO UPDATE SET total_roon = $2, reward_pool = $3`,
        [month, totalRoon, rewardPool]
      );
      res.json({ success: true, month, totalRoon, rewardPool });
    } catch (e) {
      res.json({ success: false, message: e.message });
    }
  });

  // Admin: 执行月度快照
  router.post('/admin/snapshot', auth, async (req, res) => {
    try {
      const w = req.wallet;
      if (w !== '0xfad7eb0814b6838b05191a07fb987957d50c4ca9') {
        return res.json({ success: false, message: '无权限' });
      }
      const { month } = req.body;
      if (!month) return res.json({ success: false, message: '需要month参数' });

      const types = ['power', 'pk', 'level', 'spending', 'minigame'];
      let totalInserted = 0;

      for (const type of types) {
        let rows;
        if (type === 'power') {
          rows = (await pool.query('SELECT wallet, name, combat_power as score FROM players ORDER BY combat_power DESC LIMIT 50')).rows;
        } else if (type === 'pk') {
          rows = (await pool.query('SELECT r.wallet, p.name, r.rank_score as score FROM pk_rankings r JOIN players p ON p.wallet = r.wallet ORDER BY r.rank_score DESC LIMIT 50')).rows;
        } else if (type === 'level') {
          rows = (await pool.query('SELECT wallet, name, level as score FROM players ORDER BY level DESC LIMIT 50')).rows;
        } else if (type === 'spending') {
          rows = (await pool.query('SELECT s.wallet, p.name, s.total_spent as score FROM monthly_spending s JOIN players p ON p.wallet = s.wallet WHERE s.month = $1 ORDER BY s.total_spent DESC LIMIT 50', [month])).rows;
        } else if (type === 'minigame') {
          rows = (await pool.query('SELECT s.wallet, p.name, s.total_score as score FROM minigame_scores s JOIN players p ON p.wallet = s.wallet WHERE s.month = $1 ORDER BY s.total_score DESC LIMIT 50', [month])).rows;
        }

        for (let i = 0; i < (rows || []).length; i++) {
          const r = rows[i];
          await pool.query(
            `INSERT INTO monthly_rankings (month, rank_type, rank_position, wallet, player_name, score)
             VALUES ($1, $2, $3, $4, $5, $6)
             ON CONFLICT (month, rank_type, wallet) DO UPDATE SET rank_position = $3, score = $6`,
            [month, type, i + 1, r.wallet, r.name, r.score || 0]
          );
          totalInserted++;
        }
      }

      await pool.query('UPDATE monthly_revenue SET snapshot_done = true WHERE month = $1', [month]);
      res.json({ success: true, message: `快照完成, 共${totalInserted}条记录` });
    } catch (e) {
      res.json({ success: false, message: e.message });
    }
  });

  // Admin: 分配奖励
  router.post('/admin/distribute', auth, async (req, res) => {
    try {
      const w = req.wallet;
      if (w !== '0xfad7eb0814b6838b05191a07fb987957d50c4ca9') {
        return res.json({ success: false, message: '无权限' });
      }
      const { month } = req.body;
      const rev = (await pool.query('SELECT * FROM monthly_revenue WHERE month = $1', [month])).rows[0];
      if (!rev) return res.json({ success: false, message: '未找到该月收入记录' });
      if (!rev.snapshot_done) return res.json({ success: false, message: '请先执行快照' });
      if (rev.distributed) return res.json({ success: false, message: '已分配过' });

      const pool5 = Number(rev.reward_pool);
      // 分配比例: 第1名30%, 第2-3名各15%, 第4-10名平分25%, 第11-50名平分15%
      const distribute = (rankings) => {
        for (const r of rankings) {
          let share = 0;
          if (r.rank_position === 1) share = pool5 * 0.30;
          else if (r.rank_position <= 3) share = pool5 * 0.15;
          else if (r.rank_position <= 10) share = pool5 * 0.25 / 7;
          else if (r.rank_position <= 50) share = pool5 * 0.15 / 40;
          r.reward = share;
        }
        return rankings;
      };

      // 所有5榜统一发焰晶奖励
      const types = ['power', 'pk', 'level', 'spending', 'minigame'];
      let totalDistributed = 0;
      const stoneRewards = {1:5000, 2:3000, 3:3000, 4:1000, 5:1000, 6:1000, 7:1000, 8:1000, 9:1000, 10:1000};

      for (const type of types) {
        const rankings = (await pool.query(
          'SELECT * FROM monthly_rankings WHERE month = $1 AND rank_type = $2 ORDER BY rank_position ASC',
          [month, type]
        )).rows;

        for (const r of rankings) {
          let stones = 0;
          if (r.rank_position <= 10) stones = stoneRewards[r.rank_position] || 1000;
          else if (r.rank_position <= 50) stones = 500;
          if (stones > 0) {
            await pool.query('UPDATE monthly_rankings SET reward_stones = $1 WHERE id = $2', [stones, r.id]);
            await pool.query(`UPDATE players SET game_data = jsonb_set(game_data, '{spiritStones}', to_jsonb((COALESCE((game_data->>'spiritStones')::int, 0) + $1)::int)), spirit_stones = spirit_stones + $1 WHERE wallet = $2`, [stones, r.wallet]);
            totalDistributed++;
          }
        }
      }

      await pool.query('UPDATE monthly_revenue SET distributed = true WHERE month = $1', [month]);
      res.json({ success: true, message: `奖励分配完成, ${totalDistributed}人获奖` });
    } catch (e) {
      res.json({ success: false, message: e.message });
    }
  });

  return router;
};
