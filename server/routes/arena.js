import express from 'express';
const router = express.Router();

export default function(pool, auth, runPkBattle, computeFinalStats, getMountTitleBonuses) {

  // Init tables
  const init = async () => {
    await pool.query(`
      CREATE TABLE IF NOT EXISTS arena_battles (
        id SERIAL PRIMARY KEY,
        attacker_wallet VARCHAR(100) NOT NULL,
        defender_wallet VARCHAR(100) NOT NULL,
        winner VARCHAR(100),
        attacker_score_change INT DEFAULT 0,
        defender_score_change INT DEFAULT 0,
        reward_stones INT DEFAULT 0,
        is_revenge BOOLEAN DEFAULT false,
        rounds_data JSONB,
        attacker_name VARCHAR(100),
        defender_name VARCHAR(100),
        attacker_power INT DEFAULT 0,
        defender_power INT DEFAULT 0,
        created_at TIMESTAMP DEFAULT NOW()
      );
      CREATE TABLE IF NOT EXISTS arena_notifications (
        id SERIAL PRIMARY KEY,
        wallet VARCHAR(100) NOT NULL,
        attacker_wallet VARCHAR(100) NOT NULL,
        attacker_name VARCHAR(100),
        score_change INT DEFAULT 0,
        battle_id INT,
        read BOOLEAN DEFAULT false,
        revenged BOOLEAN DEFAULT false,
        created_at TIMESTAMP DEFAULT NOW()
      );
      CREATE TABLE IF NOT EXISTS arena_daily (
        id SERIAL PRIMARY KEY,
        wallet VARCHAR(100) NOT NULL,
        date DATE NOT NULL DEFAULT CURRENT_DATE,
        challenges_used INT DEFAULT 0,
        wins INT DEFAULT 0,
        first_challenge_reward BOOLEAN DEFAULT false,
        five_win_reward BOOLEAN DEFAULT false,
        UNIQUE(wallet, date)
      );
    `);
  };
  init().catch(e => console.error('[ARENA] init error:', e.message));

  const DAILY_FREE_CHALLENGES = 5;
  const REFRESH_COOLDOWN_MS = 30 * 60 * 1000;
  const RANK_TIERS = [
    { name: 'bronze', min: 0 },
    { name: 'silver', min: 1000 },
    { name: 'gold', min: 2000 },
    { name: 'diamond', min: 3000 },
    { name: 'emperor', min: 4000 }
  ];
  const TIER_REWARDS = { bronze: 200, silver: 300, gold: 400, diamond: 500, emperor: 500 };

  function getRankTier(score) {
    for (let i = RANK_TIERS.length - 1; i >= 0; i--) {
      if (score >= RANK_TIERS[i].min) return RANK_TIERS[i].name;
    }
    return 'bronze';
  }

  function getTierIndex(tier) {
    return RANK_TIERS.findIndex(t => t.name === tier);
  }

  // Get player final stats from DB
  async function getPlayerStats(wallet) {
    const p = (await pool.query('SELECT game_data, combat_power, level, realm, name FROM players WHERE wallet=$1', [wallet])).rows[0];
    if (!p) return null;
    const gd = p.game_data || {};
    let stats;
    // Bot players: use combatAttributes directly
    if (wallet.startsWith('0xbot') && gd.combatAttributes) {
      stats = { ...gd.combatAttributes };
      // Ensure all required fields
      stats.health = stats.health || 10000;
      stats.attack = stats.attack || 1000;
      stats.defense = stats.defense || 500;
      stats.speed = stats.speed || 100;
      stats.critRate = stats.critRate || 0.15;
      stats.critDamage = stats.critDamage || 0.5;
      stats.dodgeRate = stats.dodgeRate || 0.05;
      stats.vampireRate = stats.vampireRate || 0.03;
      stats.comboRate = stats.comboRate || 0;
      stats.counterRate = stats.counterRate || 0;
      stats.stunRate = stats.stunRate || 0;
    } else {
      const bonuses = getMountTitleBonuses(gd);
      stats = computeFinalStats(gd, bonuses);
    }
    return { wallet, name: p.name || '无名修士', level: p.level, realm: p.realm, combatPower: p.combat_power || 0, stats };
  }

  // Get arena opponent list
  router.get('/opponents', auth, async (req, res) => {
    try {
      const wallet = req.user.wallet;
      // Get my rank
      await pool.query('INSERT INTO pk_rankings (wallet) VALUES ($1) ON CONFLICT DO NOTHING', [wallet]);
      const myRank = (await pool.query('SELECT rank_score, rank_tier FROM pk_rankings WHERE wallet=$1', [wallet])).rows[0];
      const myTier = myRank?.rank_tier || 'bronze';
      const myTierIdx = getTierIndex(myTier);

      // Get players in same tier only
      const tiers = [myTier];

      const opponents = (await pool.query(
        `SELECT r.wallet, r.rank_score, r.rank_tier, r.wins, r.losses, r.win_streak,
                p.name, p.level, p.realm, p.combat_power
         FROM pk_rankings r JOIN players p ON p.wallet = r.wallet
         WHERE r.rank_tier = ANY($1) AND r.wallet != $2
         ORDER BY RANDOM() LIMIT 20`,
        [tiers, wallet]
      )).rows;

      // Get daily info
      await pool.query('INSERT INTO arena_daily (wallet) VALUES ($1) ON CONFLICT DO NOTHING', [wallet]);
      const daily = (await pool.query('SELECT * FROM arena_daily WHERE wallet=$1 AND date=CURRENT_DATE', [wallet])).rows[0] || { challenges_used: 0, wins: 0 };

      // Get unread notifications count
      const notifCount = (await pool.query('SELECT count(*) as cnt FROM arena_notifications WHERE wallet=$1 AND read=false', [wallet])).rows[0]?.cnt || 0;

      res.json({
        success: true,
        opponents: opponents.map(o => ({
          wallet: o.wallet,
          name: o.name || '无名修士',
          level: o.level,
          realm: o.realm,
          combatPower: Number(o.combat_power) || 0,
          rankScore: o.rank_score,
          rankTier: o.rank_tier,
          wins: o.wins,
          losses: o.losses,
          winRate: (o.wins + o.losses) > 0 ? Math.round(o.wins / (o.wins + o.losses) * 100) : 0
        })),
        myRank: { score: myRank?.rank_score || 0, tier: myTier },
        myStreak: (await pool.query('SELECT win_streak FROM pk_rankings WHERE wallet=$1', [wallet])).rows[0]?.win_streak || 0,
        daily: { used: daily.challenges_used || 0, max: DAILY_FREE_CHALLENGES, wins: daily.wins || 0 },
        unreadNotifs: Number(notifCount)
      });
    } catch (e) {
      console.error('[ARENA] opponents error:', e.message);
      res.json({ success: false, message: e.message });
    }
  });

  // Challenge an opponent
  router.post('/challenge', auth, async (req, res) => {
    try {
      const wallet = req.user.wallet;
      const { targetWallet, isRevenge } = req.body;
      if (!targetWallet) return res.json({ success: false, message: '缺少目标' });
      if (targetWallet === wallet) return res.json({ success: false, message: '不能挑战自己' });

      // Check daily limit (revenge doesn't count)
      if (!isRevenge) {
        await pool.query('INSERT INTO arena_daily (wallet) VALUES ($1) ON CONFLICT DO NOTHING', [wallet]);
        const daily = (await pool.query('SELECT challenges_used FROM arena_daily WHERE wallet=$1 AND date=CURRENT_DATE', [wallet])).rows[0];
        if ((daily?.challenges_used || 0) >= DAILY_FREE_CHALLENGES) {
          // 付费续次: 每次200焰晶
          const EXTRA_COST = 200;
          const p = (await pool.query("SELECT game_data FROM players WHERE wallet=$1", [wallet])).rows[0];
          const stones = parseInt(p?.game_data?.spiritStones) || 0;
          if (stones < EXTRA_COST) {
            return res.json({ success: false, message: "挑战次数已用完，额外挑战需" + EXTRA_COST + "焰晶（余额不足）", needPay: true, cost: EXTRA_COST, balance: stones });
          }
          // 扣费
          await pool.query("UPDATE players SET game_data = jsonb_set(game_data, '{spiritStones}', to_jsonb((COALESCE((game_data->>'spiritStones')::int, 0) - " + EXTRA_COST + ")::int)), spirit_stones = spirit_stones - " + EXTRA_COST + " WHERE wallet = $1", [wallet]);
        }
      }

      // Anti-spam: can't challenge same person within 10 min
      if (!isRevenge) {
        const recent = (await pool.query(
          "SELECT id FROM arena_battles WHERE attacker_wallet=$1 AND defender_wallet=$2 AND created_at > NOW() - INTERVAL '10 minutes' LIMIT 1",
          [wallet, targetWallet]
        )).rows[0];
        if (recent) return res.json({ success: false, message: '10分钟内不能重复挑战同一对手' });
      }

      // Check revenge validity
      if (isRevenge) {
        const notif = (await pool.query(
          'SELECT id FROM arena_notifications WHERE wallet=$1 AND attacker_wallet=$2 AND revenged=false AND created_at > NOW() - INTERVAL \'24 hours\' LIMIT 1',
          [wallet, targetWallet]
        )).rows[0];
        if (!notif) return res.json({ success: false, message: '无法复仇（已复仇或超过24小时）' });
      }

      // Get both players stats
      const attacker = await getPlayerStats(wallet);
      const defender = await getPlayerStats(targetWallet);
      if (!attacker || !defender) return res.json({ success: false, message: '玩家数据错误' });

      // Run battle
      const result = runPkBattle(attacker.stats, defender.stats);
      const winner = result.winner === 'A' ? 'attacker' : result.winner === 'B' ? 'defender' : 'draw';

      // Calculate score changes
      await pool.query('INSERT INTO pk_rankings (wallet) VALUES ($1) ON CONFLICT DO NOTHING', [wallet]);
      await pool.query('INSERT INTO pk_rankings (wallet) VALUES ($1) ON CONFLICT DO NOTHING', [targetWallet]);
      const rA = (await pool.query('SELECT rank_score, win_streak FROM pk_rankings WHERE wallet=$1', [wallet])).rows[0];
      const rB = (await pool.query('SELECT rank_score, win_streak FROM pk_rankings WHERE wallet=$1', [targetWallet])).rows[0];

      let scoreChangeA = 0, scoreChangeB = 0, reward = 0;
      const myTier = getRankTier(rA.rank_score);

      if (winner === 'attacker') {
        const diff = rB.rank_score - rA.rank_score;
        const bonus = Math.floor(Math.max(0, diff) / 100) * 5;
        const streak = rA.win_streak >= 10 ? 20 : rA.win_streak >= 5 ? 10 : rA.win_streak >= 3 ? 5 : 0;
        scoreChangeA = Math.min(40, 25 + bonus + streak + (isRevenge ? 10 : 0));
        scoreChangeB = -Math.min(25, Math.max(10, 20 - bonus));
        reward = TIER_REWARDS[myTier] || 200;

        await pool.query('UPDATE pk_rankings SET rank_score=GREATEST(0,rank_score+$1), rank_tier=$2, wins=wins+1, win_streak=win_streak+1, max_win_streak=GREATEST(max_win_streak,win_streak+1), last_pk_at=NOW() WHERE wallet=$3',
          [scoreChangeA, getRankTier(rA.rank_score + scoreChangeA), wallet]);
        await pool.query('UPDATE pk_rankings SET rank_score=GREATEST(0,rank_score+$1), rank_tier=$2, losses=losses+1, win_streak=0, last_pk_at=NOW() WHERE wallet=$3',
          [scoreChangeB, getRankTier(Math.max(0, rB.rank_score + scoreChangeB)), targetWallet]);

        // Give reward stones
        await pool.query(`UPDATE players SET game_data = jsonb_set(game_data, '{spiritStones}', to_jsonb((COALESCE((game_data->>'spiritStones')::int, 0) + $1)::int)), spirit_stones = spirit_stones + $1 WHERE wallet = $2`, [reward, wallet]);

      } else if (winner === 'defender') {
        scoreChangeA = -Math.min(25, Math.max(10, 15));
        scoreChangeB = Math.min(15, 10);

        await pool.query('UPDATE pk_rankings SET rank_score=GREATEST(0,rank_score+$1), rank_tier=$2, losses=losses+1, win_streak=0, last_pk_at=NOW() WHERE wallet=$3',
          [scoreChangeA, getRankTier(Math.max(0, rA.rank_score + scoreChangeA)), wallet]);
        await pool.query('UPDATE pk_rankings SET rank_score=GREATEST(0,rank_score+$1), rank_tier=$2, wins=wins+1, win_streak=win_streak+1, last_pk_at=NOW() WHERE wallet=$3',
          [scoreChangeB, getRankTier(rB.rank_score + scoreChangeB), targetWallet]);
      }

      // Save battle record
      const battle = (await pool.query(
        `INSERT INTO arena_battles (attacker_wallet, defender_wallet, winner, attacker_score_change, defender_score_change, reward_stones, is_revenge, rounds_data, attacker_name, defender_name, attacker_power, defender_power)
         VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12) RETURNING id`,
        [wallet, targetWallet, winner === 'attacker' ? wallet : winner === 'defender' ? targetWallet : 'draw',
         scoreChangeA, scoreChangeB, reward, isRevenge || false, JSON.stringify(result.rounds),
         attacker.name, defender.name, attacker.combatPower, defender.combatPower]
      )).rows[0];

      // Update daily stats
      if (!isRevenge) {
        await pool.query('UPDATE arena_daily SET challenges_used = challenges_used + 1 WHERE wallet=$1 AND date=CURRENT_DATE', [wallet]);
      }
      if (winner === 'attacker') {
        await pool.query('UPDATE arena_daily SET wins = wins + 1 WHERE wallet=$1 AND date=CURRENT_DATE', [wallet]);
      }

      // Daily rewards
      let dailyReward = 0;
      const dailyAfter = (await pool.query('SELECT * FROM arena_daily WHERE wallet=$1 AND date=CURRENT_DATE', [wallet])).rows[0];
      if (!dailyAfter.first_challenge_reward) {
        dailyReward += 100;
        await pool.query('UPDATE arena_daily SET first_challenge_reward=true WHERE wallet=$1 AND date=CURRENT_DATE', [wallet]);
        await pool.query(`UPDATE players SET game_data = jsonb_set(game_data, '{spiritStones}', to_jsonb((COALESCE((game_data->>'spiritStones')::int, 0) + 100)::int)), spirit_stones = spirit_stones + 100 WHERE wallet = $1`, [wallet]);
      }
      if (dailyAfter.wins >= 5 && !dailyAfter.five_win_reward) {
        dailyReward += 500;
        await pool.query('UPDATE arena_daily SET five_win_reward=true WHERE wallet=$1 AND date=CURRENT_DATE', [wallet]);
        await pool.query(`UPDATE players SET game_data = jsonb_set(game_data, '{spiritStones}', to_jsonb((COALESCE((game_data->>'spiritStones')::int, 0) + 500)::int)), spirit_stones = spirit_stones + 500 WHERE wallet = $1`, [wallet]);
      }

      // Notify defender about being attacked (win or lose)
      await pool.query(
        'INSERT INTO arena_notifications (wallet, attacker_wallet, attacker_name, score_change, battle_id) VALUES ($1,$2,$3,$4,$5)',
        [targetWallet, wallet, attacker.name, scoreChangeB, battle.id]
      );

      // Mark revenge done
      if (isRevenge) {
        await pool.query('UPDATE arena_notifications SET revenged=true WHERE wallet=$1 AND attacker_wallet=$2 AND revenged=false', [wallet, targetWallet]);
      }

      const newRank = (await pool.query('SELECT rank_score, rank_tier FROM pk_rankings WHERE wallet=$1', [wallet])).rows[0];

      res.json({
        success: true,
        result: {
          ...result,
          winner,
          nameA: attacker.name,
          nameB: defender.name,
          levelA: attacker.level,
          levelB: defender.level,
          realmA: attacker.realm,
          realmB: defender.realm,
          maxHpA: attacker.stats.health,
          maxHpB: defender.stats.health,
          reward,
          dailyReward,
          scoreChangeA,
          scoreChangeB,
          newRankScore: newRank?.rank_score || 0,
          newRankTier: newRank?.rank_tier || 'bronze',
          isRevenge: isRevenge || false
        }
      });
    } catch (e) {
      console.error('[ARENA] challenge error:', e.message);
      res.json({ success: false, message: e.message });
    }
  });

  // Get notifications
  router.get('/notifications', auth, async (req, res) => {
    try {
      const rows = (await pool.query(
        'SELECT n.*, ab.attacker_power, ab.defender_power FROM arena_notifications n LEFT JOIN arena_battles ab ON ab.id = n.battle_id WHERE n.wallet=$1 ORDER BY n.created_at DESC LIMIT 20',
        [req.user.wallet]
      )).rows;
      // Mark as read
      await pool.query('UPDATE arena_notifications SET read=true WHERE wallet=$1 AND read=false', [req.user.wallet]);
      res.json({ success: true, notifications: rows });
    } catch (e) {
      res.json({ success: false, message: e.message });
    }
  });

  // Get battle history
  router.get('/history', auth, async (req, res) => {
    try {
      const rows = (await pool.query(
        'SELECT id, attacker_wallet, defender_wallet, winner, attacker_score_change, defender_score_change, reward_stones, is_revenge, attacker_name, defender_name, attacker_power, defender_power, created_at FROM arena_battles WHERE attacker_wallet=$1 OR defender_wallet=$1 ORDER BY created_at DESC LIMIT 30',
        [req.user.wallet]
      )).rows;
      res.json({ success: true, battles: rows });
    } catch (e) {
      res.json({ success: false, message: e.message });
    }
  });

  // Get battle replay
  router.get('/replay/:id', auth, async (req, res) => {
    try {
      const battle = (await pool.query('SELECT * FROM arena_battles WHERE id=$1', [req.params.id])).rows[0];
      if (!battle) return res.json({ success: false, message: '战斗不存在' });
      res.json({ success: true, battle });
    } catch (e) {
      res.json({ success: false, message: e.message });
    }
  });

  return router;
};
