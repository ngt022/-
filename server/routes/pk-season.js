const express = require('express');
const router = express.Router();

const SEASON_REWARDS = {
  emperor: { stones: 10000, title: '焰帝' },
  diamond: { stones: 5000, title: '焰王' },
  gold: { stones: 3000, title: '焰将' },
  silver: { stones: 1000, title: '焰士' },
  bronze: { stones: 500, title: '' }
};

const AI_OPPONENTS = [
  { name: '焰灵傀儡·初', level: 10, realm: '燃火期三层', tier: 'bronze', stats: { health: 800, attack: 50, defense: 30, speed: 10, critRate: 0.05, comboRate: 0, dodgeRate: 0.03, combatBoost: 0, finalDamageBoost: 0, finalDamageReduce: 0, resistanceBoost: 0, vampireRate: 0, counterRate: 0, dodgeResist: 0, critDamageBoost: 0, critDamageReduce: 0, vampireResist: 0, counterResist: 0 } },
  { name: '焰灵傀儡·中', level: 25, realm: '炼火期二层', tier: 'silver', stats: { health: 2000, attack: 120, defense: 80, speed: 15, critRate: 0.08, comboRate: 0.03, dodgeRate: 0.05, combatBoost: 0.05, finalDamageBoost: 0, finalDamageReduce: 0.03, resistanceBoost: 0.02, vampireRate: 0, counterRate: 0, dodgeResist: 0, critDamageBoost: 0.1, critDamageReduce: 0, vampireResist: 0, counterResist: 0 } },
  { name: '焰灵傀儡·高', level: 45, realm: '聚火期一层', tier: 'gold', stats: { health: 5000, attack: 280, defense: 180, speed: 22, critRate: 0.12, comboRate: 0.05, dodgeRate: 0.08, combatBoost: 0.1, finalDamageBoost: 0.05, finalDamageReduce: 0.05, resistanceBoost: 0.05, vampireRate: 0.03, counterRate: 0.02, dodgeResist: 0.02, critDamageBoost: 0.15, critDamageReduce: 0.03, vampireResist: 0, counterResist: 0 } },
  { name: '焰灵傀儡·极', level: 70, realm: '化火期三层', tier: 'diamond', stats: { health: 12000, attack: 600, defense: 400, speed: 30, critRate: 0.15, comboRate: 0.08, dodgeRate: 0.1, combatBoost: 0.15, finalDamageBoost: 0.08, finalDamageReduce: 0.08, resistanceBoost: 0.08, vampireRate: 0.05, counterRate: 0.05, dodgeResist: 0.05, critDamageBoost: 0.2, critDamageReduce: 0.05, vampireResist: 0.03, counterResist: 0.03 } },
  { name: '焰灵傀儡·皇', level: 95, realm: '焰天期一层', tier: 'emperor', stats: { health: 25000, attack: 1200, defense: 800, speed: 40, critRate: 0.18, comboRate: 0.1, dodgeRate: 0.12, combatBoost: 0.2, finalDamageBoost: 0.1, finalDamageReduce: 0.1, resistanceBoost: 0.1, vampireRate: 0.08, counterRate: 0.08, dodgeResist: 0.08, critDamageBoost: 0.25, critDamageReduce: 0.08, vampireResist: 0.05, counterResist: 0.05 } },
];

module.exports = function(pool, auth, runPkBattle, computeFinalStats, getMountTitleBonuses) {

  // Init tables
  const init = async () => {
    await pool.query(`
      CREATE TABLE IF NOT EXISTS pk_seasons (
        id SERIAL PRIMARY KEY,
        season_num INT NOT NULL UNIQUE,
        month VARCHAR(7) NOT NULL,
        start_date TIMESTAMP NOT NULL,
        end_date TIMESTAMP NOT NULL,
        status VARCHAR(20) DEFAULT 'active',
        created_at TIMESTAMP DEFAULT NOW()
      );
      CREATE TABLE IF NOT EXISTS pk_season_history (
        id SERIAL PRIMARY KEY,
        season_num INT NOT NULL,
        wallet VARCHAR(100) NOT NULL,
        rank_score INT DEFAULT 0,
        rank_tier VARCHAR(20) DEFAULT 'bronze',
        wins INT DEFAULT 0,
        losses INT DEFAULT 0,
        draws INT DEFAULT 0,
        max_win_streak INT DEFAULT 0,
        final_rank INT DEFAULT 0,
        reward_stones INT DEFAULT 0,
        reward_title VARCHAR(50) DEFAULT '',
        created_at TIMESTAMP DEFAULT NOW(),
        UNIQUE(season_num, wallet)
      );
    `);
  };
  init().catch(e => console.error('[PK_SEASON] init error:', e.message));

  // Get current season
  router.get('/season', auth, async (req, res) => {
    try {
      const now = new Date();
      const month = now.getFullYear() + '-' + String(now.getMonth() + 1).padStart(2, '0');
      let season = (await pool.query("SELECT * FROM pk_seasons WHERE status='active' ORDER BY season_num DESC LIMIT 1")).rows[0];
      
      if (!season) {
        // Auto-create season for current month
        const seasonNum = now.getFullYear() * 100 + (now.getMonth() + 1);
        const startDate = new Date(now.getFullYear(), now.getMonth(), 1);
        const endDate = new Date(now.getFullYear(), now.getMonth() + 1, 0, 23, 59, 59);
        await pool.query(
          'INSERT INTO pk_seasons (season_num, month, start_date, end_date) VALUES ($1, $2, $3, $4) ON CONFLICT DO NOTHING',
          [seasonNum, month, startDate, endDate]
        );
        season = (await pool.query("SELECT * FROM pk_seasons WHERE season_num=$1", [seasonNum])).rows[0];
      }

      // Days remaining
      const endDate = new Date(season.end_date);
      const daysLeft = Math.max(0, Math.ceil((endDate - now) / 86400000));

      res.json({ success: true, season: { ...season, daysLeft } });
    } catch (e) {
      res.json({ success: false, message: e.message });
    }
  });

  // Get season history
  router.get('/season/history', auth, async (req, res) => {
    try {
      const rows = (await pool.query(
        'SELECT s.season_num, s.month, h.rank_score, h.rank_tier, h.wins, h.losses, h.final_rank, h.reward_stones, h.reward_title FROM pk_season_history h JOIN pk_seasons s ON s.season_num = h.season_num WHERE h.wallet = $1 ORDER BY s.season_num DESC LIMIT 12',
        [req.wallet]
      )).rows;
      res.json({ success: true, history: rows });
    } catch (e) {
      res.json({ success: false, message: e.message });
    }
  });

  // AI Match - fight a bot
  router.post('/ai-match', auth, async (req, res) => {
    try {
      const wallet = req.wallet;
      
      // Get player stats
      const player = (await pool.query('SELECT game_data, combat_power, level, realm, name FROM players WHERE wallet=$1', [wallet])).rows[0];
      if (!player) return res.json({ success: false, message: '玩家不存在' });

      const gameData = player.game_data || {};
      const bonuses = getMountTitleBonuses(gameData);
      const playerStats = computeFinalStats(gameData, bonuses);

      // Pick AI opponent based on player combat power
      const cp = player.combat_power || 0;
      let ai;
      if (cp < 500) ai = AI_OPPONENTS[0];
      else if (cp < 2000) ai = AI_OPPONENTS[1];
      else if (cp < 8000) ai = AI_OPPONENTS[2];
      else if (cp < 20000) ai = AI_OPPONENTS[3];
      else ai = AI_OPPONENTS[4];

      // Add some randomness to AI stats (+-15%)
      const aiStats = {};
      for (const [k, v] of Object.entries(ai.stats)) {
        if (typeof v === 'number' && v > 0) {
          aiStats[k] = Math.floor(v * (0.85 + Math.random() * 0.3));
        } else {
          aiStats[k] = v;
        }
      }

      // Run battle
      const result = runPkBattle(playerStats, aiStats);
      const winner = result.winner === 'A' ? 'player' : result.winner === 'B' ? 'ai' : 'draw';

      // Rewards
      let reward = 0;
      let rankChange = 0;
      if (winner === 'player') {
        reward = 200;
        rankChange = 15;
        // Give stones
        await pool.query(
          `UPDATE players SET game_data = jsonb_set(game_data, '{spiritStones}', to_jsonb((COALESCE((game_data->>'spiritStones')::int, 0) + $1)::int)) WHERE wallet = $2`,
          [reward, wallet]
        );
        // Update rankings
        await pool.query('INSERT INTO pk_rankings (wallet) VALUES ($1) ON CONFLICT DO NOTHING', [wallet]);
        await pool.query(
          'UPDATE pk_rankings SET rank_score = rank_score + $1, wins = wins + 1, win_streak = win_streak + 1, max_win_streak = GREATEST(max_win_streak, win_streak + 1), last_pk_at = NOW() WHERE wallet = $2',
          [rankChange, wallet]
        );
      } else if (winner === 'ai') {
        rankChange = -10;
        await pool.query('INSERT INTO pk_rankings (wallet) VALUES ($1) ON CONFLICT DO NOTHING', [wallet]);
        await pool.query(
          'UPDATE pk_rankings SET rank_score = GREATEST(0, rank_score + $1), losses = losses + 1, win_streak = 0, last_pk_at = NOW() WHERE wallet = $2',
          [rankChange, wallet]
        );
      }

      // Record match
      await pool.query(
        'INSERT INTO pk_matches (wallet_a, wallet_b, winner, rounds_data, bet_amount) VALUES ($1, $2, $3, $4, 0)',
        [wallet, 'AI:' + ai.name, winner === 'player' ? wallet : winner === 'ai' ? 'AI:' + ai.name : 'draw', JSON.stringify(result.rounds)]
      );

      // Get updated rank
      const rank = (await pool.query('SELECT rank_score, rank_tier FROM pk_rankings WHERE wallet=$1', [wallet])).rows[0];

      res.json({
        success: true,
        result: {
          ...result,
          winner,
          nameA: player.name || '无名修士',
          nameB: ai.name,
          levelA: player.level,
          levelB: ai.level,
          realmA: player.realm,
          realmB: ai.realm,
          reward,
          rankChange,
          newRankScore: rank?.rank_score || 0,
          newRankTier: rank?.rank_tier || 'bronze',
          isAI: true
        }
      });
    } catch (e) {
      console.error('[AI_MATCH]', e.message);
      res.json({ success: false, message: e.message });
    }
  });

  // Admin: End season and distribute rewards
  router.post('/admin/end-season', auth, async (req, res) => {
    try {
      const w = req.wallet;
      if (w !== '0xfad7eb0814b6838b05191a07fb987957d50c4ca9') {
        return res.json({ success: false, message: '无权限' });
      }

      const season = (await pool.query("SELECT * FROM pk_seasons WHERE status='active' ORDER BY season_num DESC LIMIT 1")).rows[0];
      if (!season) return res.json({ success: false, message: '没有活跃赛季' });

      // Snapshot all rankings
      const rankings = (await pool.query(
        'SELECT wallet, rank_score, rank_tier, wins, losses, draws, max_win_streak FROM pk_rankings ORDER BY rank_score DESC'
      )).rows;

      let distributed = 0;
      for (let i = 0; i < rankings.length; i++) {
        const r = rankings[i];
        const reward = SEASON_REWARDS[r.rank_tier] || SEASON_REWARDS.bronze;
        
        await pool.query(
          `INSERT INTO pk_season_history (season_num, wallet, rank_score, rank_tier, wins, losses, draws, max_win_streak, final_rank, reward_stones, reward_title)
           VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)
           ON CONFLICT (season_num, wallet) DO NOTHING`,
          [season.season_num, r.wallet, r.rank_score, r.rank_tier, r.wins, r.losses, r.draws, r.max_win_streak, i + 1, reward.stones, reward.title]
        );

        // Give stones reward
        if (reward.stones > 0) {
          await pool.query(
            `UPDATE players SET game_data = jsonb_set(game_data, '{spiritStones}', to_jsonb((COALESCE((game_data->>'spiritStones')::int, 0) + $1)::int)) WHERE wallet = $2`,
            [reward.stones, r.wallet]
          );
        }
        distributed++;
      }

      // Reset rankings (keep wallet, reset scores with floor)
      for (const r of rankings) {
        const prevTierIdx = ['bronze', 'silver', 'gold', 'diamond', 'emperor'].indexOf(r.rank_tier);
        const newFloor = Math.max(0, (prevTierIdx - 1)) * 1000; // Drop 1 tier as floor
        await pool.query(
          'UPDATE pk_rankings SET rank_score = $1, rank_tier = $2, wins = 0, losses = 0, draws = 0, win_streak = 0, max_win_streak = 0 WHERE wallet = $3',
          [newFloor, ['bronze', 'silver', 'gold', 'diamond', 'emperor'][Math.max(0, prevTierIdx - 1)], r.wallet]
        );
      }

      // Close season
      await pool.query("UPDATE pk_seasons SET status='ended' WHERE season_num=$1", [season.season_num]);

      res.json({ success: true, message: `赛季${season.season_num}结束, ${distributed}人获奖, 段位已重置` });
    } catch (e) {
      res.json({ success: false, message: e.message });
    }
  });

  return router;
};
