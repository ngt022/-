import dotenv from 'dotenv';
dotenv.config({ path: new URL('./.env', import.meta.url).pathname });
import express from 'express';
import cors from 'cors';
import pg from 'pg';
import jwt from 'jsonwebtoken';
import { ethers } from 'ethers';
import rateLimit from 'express-rate-limit';
import { createServer } from 'http';
import { WebSocketServer } from 'ws';

const app = express();

// === 仓库容量检查 ===
const STORAGE_LIMITS = {
  equip:   { base: 100, perLevel: 20 },
  herb:    { base: 200, perLevel: 50 },
  pill:    { base: 50,  perLevel: 10 },
  pet:     { base: 30,  perLevel: 5 },
  formula: { base: 50,  perLevel: 10 },
};
function getStorageLimit(gameData, category) {
  const cfg = STORAGE_LIMITS[category];
  if (!cfg) return 9999;
  const expand = gameData.storageExpand || {};
  const level = expand[category] || 0;
  return cfg.base + cfg.perLevel * level;
}
function getStorageCount(gameData, category) {
  const items = gameData.items || [];
  switch (category) {
    case 'equip': return items.filter(i => i.type && i.type !== 'pill' && i.type !== 'pet' && i.stats).length;
    case 'pet': return items.filter(i => i.type === 'pet').length;
    case 'pill': return items.filter(i => i.type === 'pill').length;
    case 'herb': return (gameData.herbs || []).length;
    case 'formula': return (gameData.pillRecipes || []).length;
    default: return 0;
  }
}
function checkStorageCapacity(gameData, category, addCount = 1) {
  const current = getStorageCount(gameData, category);
  const limit = getStorageLimit(gameData, category);
  return { current, limit, hasSpace: current + addCount <= limit };
}
// Export for routes
global.__checkStorageCapacity = checkStorageCapacity;
global.__getStorageLimit = getStorageLimit;
global.__getStorageCount = getStorageCount;

app.set('trust proxy', 1);
const PORT = process.env.PORT || 3007;
const JWT_SECRET = process.env.JWT_SECRET || 'xiuxian_secret_2026';
const VAULT_ADDRESS = process.env.VAULT_ADDRESS || '0xBce51d77b325C1A42d2aF8359f9744699102698e';
const ROON_RPC = process.env.ROON_RPC || 'https://rpc.roonchain.com/';
const RATE_PER_ROON = 10000; // 1 ROON = 10000 灵石
const FIRST_RECHARGE_BONUS = 2; // 首充双倍

const pool = new pg.Pool({
  connectionString: process.env.DATABASE_URL || 'postgresql://roon_user:changeme@localhost:5432/xiuxian'
});

const provider = new ethers.JsonRpcProvider(ROON_RPC);

// VIP 等级配置
const VIP_CONFIG = [
  { level: 0, name: '普通', minRecharge: 0, cultivationBoost: 1, gachaDiscount: 1, extraDrop: 0 },
  { level: 1, name: 'VIP1', minRecharge: 10, cultivationBoost: 1.1, gachaDiscount: 0.95, extraDrop: 0.05 },
  { level: 2, name: 'VIP2', minRecharge: 50, cultivationBoost: 1.2, gachaDiscount: 0.9, extraDrop: 0.1 },
  { level: 3, name: 'VIP3', minRecharge: 100, cultivationBoost: 1.5, gachaDiscount: 0.85, extraDrop: 0.15 },
  { level: 4, name: 'VIP4', minRecharge: 500, cultivationBoost: 1.8, gachaDiscount: 0.8, extraDrop: 0.2 },
  { level: 5, name: 'VIP5', minRecharge: 1000, cultivationBoost: 2.0, gachaDiscount: 0.7, extraDrop: 0.3 },
];

// 签到奖励
const SIGN_REWARDS = [
  { day: 1, stones: 500, items: '强化石x2' },
  { day: 2, stones: 800, items: '洗练石x2' },
  { day: 3, stones: 1000, items: '强化石x5' },
  { day: 4, stones: 1500, items: '洗练石x5' },
  { day: 5, stones: 2000, items: '强化石x10' },
  { day: 6, stones: 3000, items: '洗练石x10' },
  { day: 7, stones: 5000, items: '神品碎片x1' },
];

app.use(cors({ origin: '*' }));
app.use(express.json({ limit: '5mb' }));
app.use(rateLimit({ windowMs: 60000, max: 120 }));

// === 认证中间件 ===
function auth(req, res, next) {
  const token = req.headers.authorization?.replace('Bearer ', '');
  if (!token) return res.status(401).json({ error: '未登录' });
  try {
    req.user = jwt.verify(token, JWT_SECRET);
    next();
  } catch { return res.status(401).json({ error: 'token无效' }); }
}

// === 钱包登录 ===
app.post('/api/auth/login', async (req, res) => {
  try {
    const { wallet, signature, message } = req.body;
    if (!wallet || !signature || !message) return res.status(400).json({ error: '参数缺失' });

    // 验证签名
    const recovered = ethers.verifyMessage(message, signature);
    if (recovered.toLowerCase() !== wallet.toLowerCase()) {
      return res.status(401).json({ error: '签名验证失败' });
    }

    // 查找或创建玩家
    let result = await pool.query('SELECT * FROM players WHERE wallet = $1', [wallet.toLowerCase()]);
    if (result.rows.length === 0) {
      result = await pool.query(
        'INSERT INTO players (wallet) VALUES ($1) RETURNING *',
        [wallet.toLowerCase()]
      );
    }

    const player = result.rows[0];
    const token = jwt.sign({ wallet: player.wallet, id: player.id }, JWT_SECRET, { expiresIn: '7d' });

    res.json({ token, player: sanitizePlayer(player) });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// === 保存游戏数据 ===
app.post('/api/game/save', auth, async (req, res) => {
  try {
    const { gameData, combatPower, level, realm, name } = req.body;
console.log("[SAVE DEBUG]", req.user.wallet.slice(-4), "level:", level, "realm:", realm, "cult:", gameData?.cultivation, "spirit:", gameData?.spirit, "stones:", gameData?.spiritStones);

    // Read DB current data - protect server-managed fields from frontend overwrite
    const current = await pool.query('SELECT game_data, level, realm, name, spirit_stones FROM players WHERE wallet = $1', [req.user.wallet]);
    if (!current.rows.length) return res.status(404).json({ error: '玩家不存在' });
    
    const oldLevel = current.rows[0]?.level || 1;
    const playerName = name || current.rows[0]?.name || '无名修士';
    const dbGameData = typeof current.rows[0].game_data === 'string' 
      ? JSON.parse(current.rows[0].game_data) 
      : (current.rows[0].game_data || {});
    
    // Server-managed fields: use DB values, never accept frontend overwrite
    const serverManagedFields = [
      'dungeonHighestFloor', 'dungeonHighestFloor_2', 'dungeonHighestFloor_5', 'dungeonHighestFloor_10', 'dungeonHighestFloor_100',
      'dungeonTotalKills', 'dungeonBossKills', 'dungeonEliteKills', 'dungeonTotalRewards', 'dungeonTotalRuns', 'dungeonDeathCount', 'dungeonLastFailedFloor','spiritStones', 'items', 'reinforceStones', 'refinementStones', 'petEssence', 
      'purchasedPacks', 'buffs', 'herbs', 'pillRecipes', 'pillFragments',
      'storageExpand', 'autoSellQualities', 'autoReleaseRarities'];
    
    // Merge: frontend data as base, but server-managed fields use DB values
    const mergedData = { ...gameData };
    for (const field of serverManagedFields) {
      if (dbGameData[field] !== undefined) {
        mergedData[field] = dbGameData[field];
      }
    }
    
    // spirit_stones column also uses DB value
    const dbSpiritStones = current.rows[0].spirit_stones ?? mergedData.spiritStones ?? 0;

    await pool.query(
      `UPDATE players SET game_data = $1, combat_power = $2, level = $3, realm = $4, 
       spirit_stones = $5, name = $6, updated_at = NOW() WHERE wallet = $7`,
      [JSON.stringify(mergedData), combatPower || 0, level || 1, realm || '燃火期一层',
       dbSpiritStones, playerName, req.user.wallet]
    );

    // Breakthrough broadcast
    if (level > oldLevel && app.locals.broadcastEvent) {
      app.locals.broadcastEvent(`⚡ ${playerName} 突破至 ${realm}！`, 'breakthrough');
    }

    // Return DB real values so frontend can sync
    res.json({ ok: true, spiritStones: dbSpiritStones, items: mergedData.items });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// === 保存游戏数据（sendBeacon 紧急存档）===
app.post('/api/game/save-beacon', async (req, res) => {
  try {
    const token = req.query.token;
    if (!token) return res.status(401).json({ error: '未登录' });
    let user;
    try { user = jwt.verify(token, JWT_SECRET); } catch { return res.status(401).json({ error: 'token无效' }); }

    const { gameData, combatPower, level, realm, name } = req.body;
console.log("[SAVE DEBUG]", req.user.wallet.slice(-4), "level:", level, "realm:", realm, "cult:", gameData?.cultivation, "spirit:", gameData?.spirit, "stones:", gameData?.spiritStones);
    const current = await pool.query('SELECT game_data, level, realm, name, spirit_stones FROM players WHERE wallet = $1', [user.wallet]);
    if (!current.rows.length) return res.status(404).json({ error: '玩家不存在' });
    
    const oldLevel = current.rows[0]?.level || 1;
    const playerName = name || current.rows[0]?.name || '无名修士';
    const dbGameData = typeof current.rows[0].game_data === 'string'
      ? JSON.parse(current.rows[0].game_data)
      : (current.rows[0].game_data || {});

    const serverManagedFields = [
      'dungeonHighestFloor', 'dungeonHighestFloor_2', 'dungeonHighestFloor_5', 'dungeonHighestFloor_10', 'dungeonHighestFloor_100',
      'dungeonTotalKills', 'dungeonBossKills', 'dungeonEliteKills', 'dungeonTotalRewards', 'dungeonTotalRuns', 'dungeonDeathCount', 'dungeonLastFailedFloor','spiritStones', 'items', 'reinforceStones', 'refinementStones', 'petEssence',
      'purchasedPacks', 'buffs', 'herbs', 'pillRecipes', 'pillFragments',
      'storageExpand', 'autoSellQualities', 'autoReleaseRarities'];

    const mergedData = { ...gameData };
    for (const field of serverManagedFields) {
      if (dbGameData[field] !== undefined) {
        mergedData[field] = dbGameData[field];
      }
    }
    const dbSpiritStones = current.rows[0].spirit_stones ?? mergedData.spiritStones ?? 0;

    await pool.query(
      `UPDATE players SET game_data = $1, combat_power = $2, level = $3, realm = $4,
       spirit_stones = $5, name = $6, updated_at = NOW() WHERE wallet = $7`,
      [JSON.stringify(mergedData), combatPower || 0, level || 1, realm || '燃火期一层',
       dbSpiritStones, playerName, user.wallet]
    );

    if (level > oldLevel && app.locals.broadcastEvent) {
      app.locals.broadcastEvent(`⚡ ${playerName} 突破至 ${realm}！`, 'breakthrough');
    }
    res.json({ ok: true });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// === 加载游戏数据 ===
app.get('/api/game/load', auth, async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM players WHERE wallet = $1', [req.user.wallet]);
    if (result.rows.length === 0) return res.status(404).json({ error: '玩家不存在' });
    res.json({ player: sanitizePlayer(result.rows[0]) });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// === 商店系统 ===
import shopRoutes from './routes/shop.js';
import gachaRoutes from './routes/gacha.js';
import equipmentRoutes from './routes/equipment.js';
import petsRoutes from './routes/pets.js';
import inventoryRoutes from './routes/inventory-gd.js';
app.use('/api/shop', shopRoutes(pool, auth));
app.use('/api/inventory', inventoryRoutes(pool, auth));

// === 探索系统 ===
import explorationRoutes from './routes/exploration.js';
import gameBalanceRoutes from "./routes/game-balance.js";
app.use("/api/admin", gameBalanceRoutes);
app.use('/api/exploration', explorationRoutes(pool, auth));
app.use('/api/gacha', gachaRoutes);
app.use('/api/equipment', equipmentRoutes);
// app.use('/api/pets', petsRoutes); // disabled: pets managed via game_data.items

// === 探索奖励同步 ===
app.post('/api/exploration/reward', auth, async (req, res) => {
  try {
    const w = req.user.wallet;
    const { type, amount } = req.body;
    if (!type || !amount || amount <= 0) return res.status(400).json({ error: '参数无效' });

    if (type === 'spirit_stone') {
      await pool.query(
        `UPDATE players SET spirit_stones = spirit_stones + $1,
         game_data = jsonb_set(game_data, '{spiritStones}', to_jsonb((COALESCE((game_data->>'spiritStones')::bigint, 0) + $1)::bigint))
         WHERE wallet = $2`,
        [amount, w]
      );
      res.json({ ok: true, type, amount });
    } else if (type === 'herb') {
      // herb reward: { herbId, name, quality, value }
      const { herbId, name, quality, value } = req.body;
      if (!herbId || !name) return res.status(400).json({ error: '焰草参数不完整' });
      // Store herb in game_data.herbs array
      const player = await pool.query('SELECT game_data FROM players WHERE wallet=$1', [w]);
      const gd = player.rows[0]?.game_data || {};
      const herbs = gd.herbs || [];
      herbs.push({ id: herbId, herbId, herb_id: herbId, name, quality: quality || 'common', value: value || 0, obtainedAt: Date.now() });
      gd.herbs = herbs;
      await pool.query('UPDATE players SET game_data=$1 WHERE wallet=$2', [JSON.stringify(gd), w]);
      res.json({ ok: true, type, herbId, name });
    } else {
      res.status(400).json({ error: '未知奖励类型' });
    }
  } catch (e) { res.status(500).json({ error: e.message }); }
});

// === 充值确认 ===
app.post('/api/recharge/confirm', auth, async (req, res) => {
  try {
    const { txHash } = req.body;
    if (!txHash) return res.status(400).json({ error: '缺少txHash' });

    // 防重放
    const existing = await pool.query('SELECT id FROM recharge_log WHERE tx_hash = $1', [txHash]);
    if (existing.rows.length > 0) return res.status(400).json({ error: '该交易已处理' });

    // 链上验证
    const tx = await provider.getTransaction(txHash);
    if (!tx) return res.status(400).json({ error: '交易不存在' });
    if (tx.to?.toLowerCase() !== VAULT_ADDRESS.toLowerCase()) {
      return res.status(400).json({ error: '收款地址不匹配' });
    }
    if (tx.from?.toLowerCase() !== req.user.wallet.toLowerCase()) {
      return res.status(400).json({ error: '发送地址不匹配' });
    }

    const receipt = await provider.getTransactionReceipt(txHash);
    if (!receipt || receipt.status !== 1) return res.status(400).json({ error: '交易未确认' });

    const amount = parseFloat(ethers.formatEther(tx.value));
    if (amount <= 0) return res.status(400).json({ error: '金额无效' });

    let spiritStones = Math.floor(amount * RATE_PER_ROON);
    let bonusStones = 0;

    // 首充双倍
    const player = await pool.query('SELECT first_recharge, total_recharge, vip_level FROM players WHERE wallet = $1', [req.user.wallet]);
    if (!player.rows[0].first_recharge) {
      bonusStones = spiritStones; // 双倍
      spiritStones *= FIRST_RECHARGE_BONUS;
    }

    // 计算新VIP等级
    const newTotal = parseFloat(player.rows[0].total_recharge) + amount;
    let newVipLevel = 0;
    for (let i = VIP_CONFIG.length - 1; i >= 0; i--) {
      if (newTotal >= VIP_CONFIG[i].minRecharge) { newVipLevel = VIP_CONFIG[i].level; break; }
    }

    // 记录充值
    await pool.query(
      'INSERT INTO recharge_log (wallet, tx_hash, amount, spirit_stones, bonus_stones) VALUES ($1,$2,$3,$4,$5)',
      [req.user.wallet, txHash, amount, spiritStones, bonusStones]
    );

    // 更新玩家
    await pool.query(
      `UPDATE players SET spirit_stones = spirit_stones + $1, total_recharge = total_recharge + $2,
       vip_level = $3, first_recharge = TRUE,
       game_data = jsonb_set(game_data, '{spiritStones}', to_jsonb((COALESCE((game_data->>'spiritStones')::bigint, 0) + $1)::bigint)),
       updated_at = NOW() WHERE wallet = $4`,
      [spiritStones, amount, newVipLevel, req.user.wallet]
    );

    res.json({
      ok: true, amount, spiritStones, bonusStones,
      isFirstRecharge: !player.rows[0].first_recharge,
      vipLevel: newVipLevel,
      totalRecharge: newTotal
    });

    // 全服广播充值
    const pName = (await pool.query('SELECT name FROM players WHERE wallet=$1', [req.user.wallet])).rows[0]?.name || '无名修士';
    if (newVipLevel > player.rows[0].vip_level) {
      app.locals.broadcastEvent(`🎉 ${pName} 晋升为 VIP${newVipLevel}！`, 'vip');
    }
    if (!player.rows[0].first_recharge) {
      app.locals.broadcastEvent(`✨ ${pName} 完成了首充，获得双倍灵石！`, 'recharge');
    }
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// === VIP 信息 ===
app.get('/api/vip/info', auth, async (req, res) => {
  try {
    const result = await pool.query('SELECT vip_level, total_recharge FROM players WHERE wallet = $1', [req.user.wallet]);
    const player = result.rows[0];
    const current = VIP_CONFIG[player.vip_level];
    const next = VIP_CONFIG[player.vip_level + 1] || null;
    res.json({
      vipLevel: player.vip_level,
      vipName: current.name,
      totalRecharge: player.total_recharge,
      benefits: current,
      nextLevel: next ? { need: next.minRecharge - parseFloat(player.total_recharge), benefits: next } : null,
      allLevels: VIP_CONFIG
    });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// === 每日签到 ===
app.post('/api/sign/daily', auth, async (req, res) => {
  try {
    const result = await pool.query('SELECT daily_sign_date::text, daily_sign_streak FROM players WHERE wallet = $1', [req.user.wallet]);
    const player = result.rows[0];
    const today = new Date().toISOString().split('T')[0];

    if (player.daily_sign_date === today) return res.status(400).json({ error: '今天已签到' });

    const yesterday = new Date(Date.now() - 86400000).toISOString().split('T')[0];
    let streak = player.daily_sign_date === yesterday ? player.daily_sign_streak + 1 : 1;
    if (streak > 7) streak = 1;

    const reward = SIGN_REWARDS[(streak - 1) % 7];

    await pool.query(
      `UPDATE players SET daily_sign_date = $1, daily_sign_streak = $2, 
       spirit_stones = spirit_stones + $3,
       game_data = jsonb_set(game_data, '{spiritStones}', to_jsonb((COALESCE((game_data->>'spiritStones')::bigint, 0) + $3)::bigint)),
       updated_at = NOW() WHERE wallet = $4`,
      [today, streak, reward.stones, req.user.wallet]
    );

    res.json({ ok: true, streak, reward });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// === 排行榜 ===
app.get('/api/leaderboard/:type', async (req, res) => {
  try {
    const { type } = req.params;
    let query;
    switch (type) {
      case 'power':
        query = 'SELECT name, wallet, combat_power, level, realm, vip_level FROM players ORDER BY combat_power DESC LIMIT 50';
        break;
      case 'level':
        query = 'SELECT name, wallet, combat_power, level, realm, vip_level FROM players ORDER BY level DESC, combat_power DESC LIMIT 50';
        break;
      case 'recharge':
        query = 'SELECT name, wallet, total_recharge, vip_level FROM players ORDER BY total_recharge DESC LIMIT 50';
        break;
      default:
        return res.status(400).json({ error: '无效排行类型' });
    }
    const result = await pool.query(query);
    // 隐藏钱包中间部分
    const data = result.rows.map((r, i) => ({
      rank: i + 1,
      ...r,
      wallet: r.wallet.slice(0, 6) + '...' + r.wallet.slice(-4)
    }));
    res.json({ type, data });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// === 充值记录 ===
app.get('/api/recharge/history', auth, async (req, res) => {
  try {
    const result = await pool.query(
      'SELECT amount, spirit_stones, bonus_stones, created_at FROM recharge_log WHERE wallet = $1 ORDER BY created_at DESC LIMIT 20',
      [req.user.wallet]
    );
    res.json({ records: result.rows });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

function sanitizePlayer(p) {
  return {
    id: p.id, wallet: p.wallet, name: p.name, gameData: p.game_data,
    vipLevel: p.vip_level, totalRecharge: p.total_recharge,
    spiritStones: p.spirit_stones, level: p.level, realm: p.realm,
    combatPower: p.combat_power, firstRecharge: p.first_recharge,
    dailySignDate: p.daily_sign_date ? (p.daily_sign_date instanceof Date ? p.daily_sign_date.toISOString().split("T")[0] : String(p.daily_sign_date).split("T")[0]) : null, dailySignStreak: p.daily_sign_streak
  };
}

// === 月卡系统 ===
const MONTHLY_CARD_PRICE = 10; // 10 ROON
const MONTHLY_CARD_DAILY = 5000; // 每日5000灵石
const MONTHLY_CARD_DAYS = 30;

// 查询月卡状态
app.get('/api/monthly-card/status', auth, async (req, res) => {
  try {
    const result = await pool.query(
      'SELECT * FROM monthly_cards WHERE wallet = $1 AND expires_at > NOW() ORDER BY expires_at DESC LIMIT 1',
      [req.user.wallet]
    );
    if (result.rows.length === 0) {
      return res.json({ active: false });
    }
    const card = result.rows[0];
    const today = new Date().toISOString().split('T')[0];
    const claimed = card.last_claim_date === today;
    res.json({
      active: true,
      expiresAt: card.expires_at,
      daysClaimed: card.days_claimed,
      claimedToday: claimed,
      dailyReward: MONTHLY_CARD_DAILY,
      perks: {
        cultivationBoost: 1.2, // 修炼加速20%
        freeGacha: 1, // 每日免费抽卡1次
      }
    });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// 购买月卡（链上验证）
app.post('/api/monthly-card/buy', auth, async (req, res) => {
  try {
    const { txHash } = req.body;
    if (!txHash) return res.status(400).json({ error: '缺少txHash' });

    // 防重放
    const existing = await pool.query('SELECT id FROM recharge_log WHERE tx_hash = $1', [txHash]);
    if (existing.rows.length > 0) return res.status(400).json({ error: '该交易已处理' });

    // 链上验证
    const tx = await provider.getTransaction(txHash);
    if (!tx) return res.status(400).json({ error: '交易不存在' });
    if (tx.to?.toLowerCase() !== VAULT_ADDRESS.toLowerCase()) return res.status(400).json({ error: '收款地址不匹配' });
    if (tx.from?.toLowerCase() !== req.user.wallet.toLowerCase()) return res.status(400).json({ error: '发送地址不匹配' });

    const receipt = await provider.getTransactionReceipt(txHash);
    if (!receipt || receipt.status !== 1) return res.status(400).json({ error: '交易未确认' });

    const amount = parseFloat(ethers.formatEther(tx.value));
    if (amount < MONTHLY_CARD_PRICE) return res.status(400).json({ error: `需要 ${MONTHLY_CARD_PRICE} ROON` });

    // 记录充值
    await pool.query(
      'INSERT INTO recharge_log (wallet, tx_hash, amount, spirit_stones, bonus_stones) VALUES ($1,$2,$3,0,0)',
      [req.user.wallet, txHash, amount]
    );

    // 创建/续期月卡
    const current = await pool.query(
      'SELECT expires_at FROM monthly_cards WHERE wallet = $1 AND expires_at > NOW() ORDER BY expires_at DESC LIMIT 1',
      [req.user.wallet]
    );
    let expiresAt;
    if (current.rows.length > 0) {
      // 续期：在现有到期时间上加30天
      expiresAt = new Date(new Date(current.rows[0].expires_at).getTime() + MONTHLY_CARD_DAYS * 86400000);
    } else {
      expiresAt = new Date(Date.now() + MONTHLY_CARD_DAYS * 86400000);
    }

    await pool.query(
      'INSERT INTO monthly_cards (wallet, expires_at) VALUES ($1, $2)',
      [req.user.wallet, expiresAt]
    );

    // 更新充值总额和VIP
    const player = await pool.query('SELECT total_recharge FROM players WHERE wallet = $1', [req.user.wallet]);
    const newTotal = parseFloat(player.rows[0].total_recharge) + amount;
    let newVipLevel = 0;
    for (let i = VIP_CONFIG.length - 1; i >= 0; i--) {
      if (newTotal >= VIP_CONFIG[i].minRecharge) { newVipLevel = VIP_CONFIG[i].level; break; }
    }
    await pool.query(
      'UPDATE players SET total_recharge = total_recharge + $1, vip_level = $2 WHERE wallet = $3',
      [amount, newVipLevel, req.user.wallet]
    );

    // 全服广播
    const pName = (await pool.query('SELECT name FROM players WHERE wallet=$1', [req.user.wallet])).rows[0]?.name || '无名修士';
    if (app.locals.broadcastEvent) {
      app.locals.broadcastEvent(`💳 ${pName} 开通了月卡！`, 'monthlycard');
    }

    res.json({ ok: true, expiresAt, dailyReward: MONTHLY_CARD_DAILY });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// 领取月卡每日灵石
app.post('/api/monthly-card/claim', auth, async (req, res) => {
  try {
    const result = await pool.query(
      'SELECT * FROM monthly_cards WHERE wallet = $1 AND expires_at > NOW() ORDER BY expires_at DESC LIMIT 1',
      [req.user.wallet]
    );
    if (result.rows.length === 0) return res.status(400).json({ error: '未开通月卡' });

    const card = result.rows[0];
    const today = new Date().toISOString().split('T')[0];
    if (card.last_claim_date === today) return res.status(400).json({ error: '今日已领取' });

    await pool.query(
      'UPDATE monthly_cards SET last_claim_date = $1, days_claimed = days_claimed + 1 WHERE id = $2',
      [today, card.id]
    );

    await pool.query(
      `UPDATE players SET spirit_stones = spirit_stones + $1,
       game_data = jsonb_set(game_data, '{spiritStones}', to_jsonb((COALESCE((game_data->>'spiritStones')::bigint, 0) + $1)::bigint))
       WHERE wallet = $2`,
      [MONTHLY_CARD_DAILY, req.user.wallet]
    );

    res.json({ ok: true, stones: MONTHLY_CARD_DAILY, daysClaimed: card.days_claimed + 1 });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// === 限时活动 ===
app.get('/api/events/active', async (req, res) => {
  try {
    const result = await pool.query(
      'SELECT id, name, type, description, config, rewards, starts_at, ends_at FROM events WHERE active = TRUE AND starts_at <= NOW() AND ends_at > NOW() ORDER BY created_at DESC'
    );
    res.json({ events: result.rows });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// 活动效果汇总（前端修炼/抽卡时调用）
app.get('/api/events/effects', async (req, res) => {
  try {
    const result = await pool.query(
      "SELECT type, config FROM events WHERE active = TRUE AND starts_at <= NOW() AND ends_at > NOW()"
    );
    const effects = { cultivationMultiplier: 1, gachaRateBoost: 1, dropMultiplier: 1, shopDiscount: 1 };
    for (const evt of result.rows) {
      const cfg = evt.config || {};
      if (evt.type === 'double_cultivation') effects.cultivationMultiplier *= (cfg.multiplier || 2);
      if (evt.type === 'gacha_rate_up') effects.gachaRateBoost *= (cfg.rateBoost || 1.5);
      if (evt.type === 'double_drop') effects.dropMultiplier *= (cfg.multiplier || 2);
      if (evt.type === 'discount') effects.shopDiscount *= (cfg.discount || 0.8);
    }
    res.json({ effects });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// 领取活动奖励（登录奖励等）
app.post('/api/events/:id/claim', auth, async (req, res) => {
  try {
    const eventId = parseInt(req.params.id);
    if (isNaN(eventId)) return res.status(400).json({ error: '无效的活动ID' });
    const wallet = req.user.wallet.toLowerCase();
    // 检查活动是否有效
    const evt = await pool.query(
      'SELECT * FROM events WHERE id = $1 AND active = TRUE AND starts_at <= NOW() AND ends_at > NOW()', [eventId]
    );
    if (evt.rows.length === 0) return res.status(404).json({ error: '活动不存在或已结束' });
    // 检查是否已领取
    const claimed = await pool.query(
      'SELECT id FROM event_claims WHERE event_id = $1 AND wallet = $2', [eventId, wallet]
    );
    if (claimed.rows.length > 0) return res.status(400).json({ error: '已领取过该活动奖励' });
    // 计算奖励
    const config = evt.rows[0].config || {};
    let stonesReward = 0;
    if (evt.rows[0].type === 'login_bonus') {
      stonesReward = config.dailyStones || 2000;
    }
    // 记录领取
    await pool.query('INSERT INTO event_claims (event_id, wallet) VALUES ($1, $2)', [eventId, wallet]);
    // 发放灵石
    if (stonesReward > 0) {
      await pool.query(
        `UPDATE players SET spirit_stones = spirit_stones + $1,
         game_data = jsonb_set(game_data, '{spiritStones}', to_jsonb((COALESCE((game_data->>'spiritStones')::bigint, 0) + $1)::bigint))
         WHERE wallet = $2`,
        [stonesReward, wallet]
      );
    }
    res.json({ ok: true, stones: stonesReward });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// === PK 历史记录 ===
app.get('/api/pk/history', auth, async (req, res) => {
  try {
    const wallet = req.user.wallet.toLowerCase();
    const result = await pool.query(
      `SELECT id, name_a, name_b, winner, winner_wallet, reward, created_at,
        wallet_a, wallet_b
       FROM pk_records WHERE wallet_a = $1 OR wallet_b = $1
       ORDER BY created_at DESC LIMIT 50`, [wallet]
    );
    const records = result.rows.map(r => ({
      ...r,
      isMe: r.winner_wallet === wallet ? 'win' : r.winner === 'draw' ? 'draw' : 'lose',
      opponent: r.wallet_a === wallet ? r.name_b : r.name_a
    }));
    res.json({ records });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// PK 战绩统计
app.get('/api/pk/stats', auth, async (req, res) => {
  try {
    const wallet = req.user.wallet.toLowerCase();
    const total = await pool.query('SELECT COUNT(*) FROM pk_records WHERE wallet_a = $1 OR wallet_b = $1', [wallet]);
    const wins = await pool.query('SELECT COUNT(*) FROM pk_records WHERE winner_wallet = $1', [wallet]);
    const totalReward = await pool.query('SELECT COALESCE(SUM(reward), 0) as total FROM pk_records WHERE winner_wallet = $1', [wallet]);
    res.json({
      total: parseInt(total.rows[0].count),
      wins: parseInt(wins.rows[0].count),
      losses: parseInt(total.rows[0].count) - parseInt(wins.rows[0].count),
      totalReward: parseInt(totalReward.rows[0].total)
    });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// === 公告系统 ===
app.get('/api/announcements', async (req, res) => {
  try {
    const result = await pool.query(
      'SELECT id, content, type FROM announcements WHERE active = TRUE ORDER BY sort_order ASC, created_at DESC LIMIT 20'
    );
    res.json({ announcements: result.rows });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});


// === 宗门系统 ===
const SECT_LEVEL_EXP = [0, 1000, 3000, 8000, 20000, 50000, 100000, 200000, 500000, 1000000];
const SECT_TASK_POOL = {
  daily: [
    { title: '灵气采集', description: '采集天地灵气，为宗门积蓄力量', reward_contribution: 10, reward_stones: 200 },
    { title: '巡山护法', description: '巡视宗门山门，驱逐妖兽', reward_contribution: 15, reward_stones: 300 },
    { title: '阵法维护', description: '维护宗门护山大阵', reward_contribution: 12, reward_stones: 250 },
    { title: '丹药炼制', description: '为宗门炼制基础丹药', reward_contribution: 20, reward_stones: 400 },
    { title: '弟子指导', description: '指导新入门弟子修炼', reward_contribution: 8, reward_stones: 150 },
    { title: '灵田耕种', description: '打理宗门灵田', reward_contribution: 10, reward_stones: 200 },
  ],
  weekly: [
    { title: '秘境探索', description: '探索宗门秘境，寻找珍稀资源', reward_contribution: 50, reward_stones: 1500 },
    { title: '宗门大比', description: '参加宗门内部切磋大比', reward_contribution: 80, reward_stones: 2000 },
    { title: '妖兽讨伐', description: '讨伐威胁宗门的强大妖兽', reward_contribution: 60, reward_stones: 1800 },
    { title: '资源运送', description: '护送珍贵资源回宗门', reward_contribution: 70, reward_stones: 2500 },
  ]
};

function randomTasks(pool, count) {
  const shuffled = [...pool].sort(() => Math.random() - 0.5);
  return shuffled.slice(0, count);
}

async function ensureSectTasks(sectId) {
  const now = new Date();
  const todayStart = new Date(now); todayStart.setHours(0,0,0,0);
  const weekStart = new Date(now); weekStart.setDate(weekStart.getDate() - weekStart.getDay()); weekStart.setHours(0,0,0,0);

  // Check daily tasks
  const dailyCheck = await pool.query(
    `SELECT id FROM sect_tasks WHERE sect_id=$1 AND type='daily' AND reset_at >= $2`, [sectId, todayStart]
  );
  if (dailyCheck.rows.length === 0) {
    await pool.query(`DELETE FROM sect_tasks WHERE sect_id=$1 AND type='daily'`, [sectId]);
    const dailies = randomTasks(SECT_TASK_POOL.daily, 3);
    for (const t of dailies) {
      await pool.query(
        `INSERT INTO sect_tasks (sect_id, type, title, description, reward_contribution, reward_stones, reset_at) VALUES ($1,'daily',$2,$3,$4,$5,$6)`,
        [sectId, t.title, t.description, t.reward_contribution, t.reward_stones, now]
      );
    }
  }

  // Check weekly tasks
  const weeklyCheck = await pool.query(
    `SELECT id FROM sect_tasks WHERE sect_id=$1 AND type='weekly' AND reset_at >= $2`, [sectId, weekStart]
  );
  if (weeklyCheck.rows.length === 0) {
    await pool.query(`DELETE FROM sect_tasks WHERE sect_id=$1 AND type='weekly'`, [sectId]);
    const weeklies = randomTasks(SECT_TASK_POOL.weekly, 1);
    for (const t of weeklies) {
      await pool.query(
        `INSERT INTO sect_tasks (sect_id, type, title, description, reward_contribution, reward_stones, reset_at) VALUES ($1,'weekly',$2,$3,$4,$5,$6)`,
        [sectId, t.title, t.description, t.reward_contribution, t.reward_stones, now]
      );
    }
  }
}

async function checkSectLevelUp(sectId) {
  const sect = await pool.query('SELECT level, exp FROM sects WHERE id=$1', [sectId]);
  if (!sect.rows.length) return;
  let { level, exp } = sect.rows[0];
  while (level < 10 && exp >= SECT_LEVEL_EXP[level]) {
    level++;
    await pool.query('UPDATE sects SET level=$1, max_members=$2 WHERE id=$3', [level, 20 + (level-1)*5, sectId]);
  }
}

// POST /api/sect/create
app.post('/api/sect/create', auth, async (req, res) => {
  try {
    const { name, description } = req.body;
    if (!name || name.length < 2 || name.length > 20) return res.status(400).json({ error: '宗门名称2-20字' });
    const existing = await pool.query('SELECT id FROM sect_members WHERE wallet=$1', [req.user.wallet]);
    if (existing.rows.length > 0) return res.status(400).json({ error: '你已加入宗门' });
    const player = await pool.query('SELECT spirit_stones, game_data FROM players WHERE wallet=$1', [req.user.wallet]);
    if (!player.rows.length) return res.status(400).json({ error: '玩家不存在' });
    const gameData = typeof player.rows[0].game_data === 'string' ? JSON.parse(player.rows[0].game_data) : player.rows[0].game_data;
    const stones = gameData?.spiritStones ?? player.rows[0].spirit_stones ?? 0;
    if (stones < 50000) return res.status(400).json({ error: '灵石不足，需要50000灵石' });
    // Deduct stones
    gameData.spiritStones = (gameData.spiritStones || 0) - 50000;
    await pool.query('UPDATE players SET game_data=$1, spirit_stones=$2 WHERE wallet=$3',
      [JSON.stringify(gameData), gameData.spiritStones, req.user.wallet]);
    const sect = await pool.query(
      'INSERT INTO sects (name, description, leader_wallet) VALUES ($1,$2,$3) RETURNING *',
      [name, description || '', req.user.wallet]
    );
    await pool.query(
      'INSERT INTO sect_members (sect_id, wallet, role) VALUES ($1,$2,$3)',
      [sect.rows[0].id, req.user.wallet, 'leader']
    );
    res.json({ ok: true, sect: sect.rows[0] });
  } catch (e) {
    if (e.code === '23505') return res.status(400).json({ error: '宗门名称已存在' });
    res.status(500).json({ error: e.message });
  }
});

// GET /api/sect/my
app.get('/api/sect/my', auth, async (req, res) => {
  try {
    const mem = await pool.query('SELECT * FROM sect_members WHERE wallet=$1', [req.user.wallet]);
    if (!mem.rows.length) return res.json({ sect: null });
    const sect = await pool.query('SELECT * FROM sects WHERE id=$1', [mem.rows[0].sect_id]);
    const members = await pool.query(
      `SELECT sm.wallet, sm.role, sm.contribution, sm.joined_at, p.name, p.level, p.realm, p.combat_power
       FROM sect_members sm LEFT JOIN players p ON sm.wallet = p.wallet WHERE sm.sect_id=$1 ORDER BY sm.role='leader' DESC, sm.role='elder' DESC, sm.contribution DESC`,
      [mem.rows[0].sect_id]
    );
    res.json({ sect: sect.rows[0], myRole: mem.rows[0].role, myContribution: mem.rows[0].contribution, members: members.rows });
  } catch (e) { res.status(500).json({ error: e.message }); }
});

// GET /api/sect/list
app.get('/api/sect/list', auth, async (req, res) => {
  try {
    const { search, sort } = req.query;
    let q = `SELECT s.*, COUNT(sm.id) as member_count FROM sects s LEFT JOIN sect_members sm ON s.id=sm.sect_id`;
    const params = [];
    if (search) { q += ` WHERE s.name ILIKE $1`; params.push(`%${search}%`); }
    q += ` GROUP BY s.id`;
    if (sort === 'level') q += ` ORDER BY s.level DESC, s.exp DESC`;
    else if (sort === 'members') q += ` ORDER BY member_count DESC`;
    else q += ` ORDER BY s.created_at DESC`;
    const result = await pool.query(q, params);
    res.json({ sects: result.rows });
  } catch (e) { res.status(500).json({ error: e.message }); }
});

// POST /api/sect/join
app.post('/api/sect/join', auth, async (req, res) => {
  try {
    const { sectId } = req.body;
    if (!sectId || isNaN(parseInt(sectId))) return res.status(400).json({ error: '无效的宗门ID' });
    const existing = await pool.query('SELECT id FROM sect_members WHERE wallet=$1', [req.user.wallet]);
    if (existing.rows.length > 0) return res.status(400).json({ error: '你已加入宗门' });
    const sect = await pool.query('SELECT * FROM sects WHERE id=$1', [sectId]);
    if (!sect.rows.length) return res.status(400).json({ error: '宗门不存在' });
    const count = await pool.query('SELECT COUNT(*) FROM sect_members WHERE sect_id=$1', [sectId]);
    if (parseInt(count.rows[0].count) >= sect.rows[0].max_members) return res.status(400).json({ error: '宗门已满' });
    await pool.query('INSERT INTO sect_members (sect_id, wallet, role) VALUES ($1,$2,$3)', [sectId, req.user.wallet, 'member']);
    res.json({ ok: true });
  } catch (e) { res.status(500).json({ error: e.message }); }
});

// POST /api/sect/leave
app.post('/api/sect/leave', auth, async (req, res) => {
  try {
    const mem = await pool.query('SELECT * FROM sect_members WHERE wallet=$1', [req.user.wallet]);
    if (!mem.rows.length) return res.status(400).json({ error: '你未加入宗门' });
    if (mem.rows[0].role === 'leader') return res.status(400).json({ error: '掌门不能退出，请先转让掌门' });
    await pool.query('DELETE FROM sect_members WHERE wallet=$1', [req.user.wallet]);
    res.json({ ok: true });
  } catch (e) { res.status(500).json({ error: e.message }); }
});

// POST /api/sect/kick
app.post('/api/sect/kick', auth, async (req, res) => {
  try {
    const { wallet } = req.body;
    const me = await pool.query('SELECT * FROM sect_members WHERE wallet=$1', [req.user.wallet]);
    if (!me.rows.length || (me.rows[0].role !== 'leader' && me.rows[0].role !== 'elder')) return res.status(403).json({ error: '权限不足' });
    const target = await pool.query('SELECT * FROM sect_members WHERE wallet=$1 AND sect_id=$2', [wallet, me.rows[0].sect_id]);
    if (!target.rows.length) return res.status(400).json({ error: '该玩家不在宗门中' });
    if (target.rows[0].role === 'leader') return res.status(400).json({ error: '不能踢掌门' });
    if (me.rows[0].role === 'elder' && target.rows[0].role === 'elder') return res.status(400).json({ error: '长老不能踢长老' });
    await pool.query('DELETE FROM sect_members WHERE wallet=$1', [wallet]);
    res.json({ ok: true });
  } catch (e) { res.status(500).json({ error: e.message }); }
});

// POST /api/sect/promote
app.post('/api/sect/promote', auth, async (req, res) => {
  try {
    const { wallet } = req.body;
    const me = await pool.query('SELECT * FROM sect_members WHERE wallet=$1', [req.user.wallet]);
    if (!me.rows.length || me.rows[0].role !== 'leader') return res.status(403).json({ error: '只有掌门可以升职' });
    const target = await pool.query('SELECT * FROM sect_members WHERE wallet=$1 AND sect_id=$2', [wallet, me.rows[0].sect_id]);
    if (!target.rows.length) return res.status(400).json({ error: '该玩家不在宗门中' });
    if (target.rows[0].role === 'leader') return res.status(400).json({ error: '已是掌门' });
    if (target.rows[0].role === 'elder') return res.status(400).json({ error: '已是长老' });
    await pool.query('UPDATE sect_members SET role=$1 WHERE wallet=$2', ['elder', wallet]);
    res.json({ ok: true });
  } catch (e) { res.status(500).json({ error: e.message }); }
});

// POST /api/sect/demote
app.post('/api/sect/demote', auth, async (req, res) => {
  try {
    const { wallet } = req.body;
    const me = await pool.query('SELECT * FROM sect_members WHERE wallet=$1', [req.user.wallet]);
    if (!me.rows.length || me.rows[0].role !== 'leader') return res.status(403).json({ error: '只有掌门可以降职' });
    const target = await pool.query('SELECT * FROM sect_members WHERE wallet=$1 AND sect_id=$2', [wallet, me.rows[0].sect_id]);
    if (!target.rows.length) return res.status(400).json({ error: '该玩家不在宗门中' });
    if (target.rows[0].role !== 'elder') return res.status(400).json({ error: '只能降职长老' });
    await pool.query('UPDATE sect_members SET role=$1 WHERE wallet=$2', ['member', wallet]);
    res.json({ ok: true });
  } catch (e) { res.status(500).json({ error: e.message }); }
});

// POST /api/sect/announcement
app.post('/api/sect/announcement', auth, async (req, res) => {
  try {
    const { announcement } = req.body;
    if (!announcement || announcement.length > 200) return res.status(400).json({ error: '公告不能为空且不超过200字' });
    const me = await pool.query('SELECT * FROM sect_members WHERE wallet=$1', [req.user.wallet]);
    if (!me.rows.length || (me.rows[0].role !== 'leader' && me.rows[0].role !== 'elder')) return res.status(403).json({ error: '权限不足' });
    await pool.query('UPDATE sects SET announcement=$1 WHERE id=$2', [announcement, me.rows[0].sect_id]);
    res.json({ ok: true });
  } catch (e) { res.status(500).json({ error: e.message }); }
});

// GET /api/sect/tasks
app.get('/api/sect/tasks', auth, async (req, res) => {
  try {
    const mem = await pool.query('SELECT * FROM sect_members WHERE wallet=$1', [req.user.wallet]);
    if (!mem.rows.length) return res.status(400).json({ error: '你未加入宗门' });
    await ensureSectTasks(mem.rows[0].sect_id);
    const tasks = await pool.query('SELECT * FROM sect_tasks WHERE sect_id=$1 ORDER BY type, id', [mem.rows[0].sect_id]);
    res.json({ tasks: tasks.rows });
  } catch (e) { res.status(500).json({ error: e.message }); }
});

// POST /api/sect/tasks/:id/complete
app.post('/api/sect/tasks/:id/complete', auth, async (req, res) => {
  try {
    const taskId = req.params.id;
    const mem = await pool.query('SELECT * FROM sect_members WHERE wallet=$1', [req.user.wallet]);
    if (!mem.rows.length) return res.status(400).json({ error: '你未加入宗门' });
    const task = await pool.query('SELECT * FROM sect_tasks WHERE id=$1 AND sect_id=$2', [taskId, mem.rows[0].sect_id]);
    if (!task.rows.length) return res.status(400).json({ error: '任务不存在' });
    const completedBy = task.rows[0].completed_by || [];
    if (completedBy.includes(req.user.wallet)) return res.status(400).json({ error: '你已完成该任务' });
    completedBy.push(req.user.wallet);
    await pool.query('UPDATE sect_tasks SET completed_by=$1 WHERE id=$2', [JSON.stringify(completedBy), taskId]);
    // Add contribution
    await pool.query('UPDATE sect_members SET contribution=contribution+$1 WHERE wallet=$2', [task.rows[0].reward_contribution, req.user.wallet]);
    // Add stones to player
    const player = await pool.query('SELECT game_data FROM players WHERE wallet=$1', [req.user.wallet]);
    const gameData = typeof player.rows[0].game_data === 'string' ? JSON.parse(player.rows[0].game_data) : player.rows[0].game_data;
    gameData.spiritStones = (gameData.spiritStones || 0) + task.rows[0].reward_stones;
    await pool.query('UPDATE players SET game_data=$1, spirit_stones=$2 WHERE wallet=$3',
      [JSON.stringify(gameData), gameData.spiritStones, req.user.wallet]);
    res.json({ ok: true, reward_contribution: task.rows[0].reward_contribution, reward_stones: task.rows[0].reward_stones });
  } catch (e) { res.status(500).json({ error: e.message }); }
});

// POST /api/sect/donate
app.post('/api/sect/donate', auth, async (req, res) => {
  try {
    const { amount } = req.body;
    if (!amount || amount < 100) return res.status(400).json({ error: '最少捐献100灵石' });
    const mem = await pool.query('SELECT * FROM sect_members WHERE wallet=$1', [req.user.wallet]);
    if (!mem.rows.length) return res.status(400).json({ error: '你未加入宗门' });
    const player = await pool.query('SELECT game_data FROM players WHERE wallet=$1', [req.user.wallet]);
    const gameData = typeof player.rows[0].game_data === 'string' ? JSON.parse(player.rows[0].game_data) : player.rows[0].game_data;
    const stones = gameData?.spiritStones ?? 0;
    if (stones < amount) return res.status(400).json({ error: '灵石不足' });
    gameData.spiritStones = stones - amount;
    await pool.query('UPDATE players SET game_data=$1, spirit_stones=$2 WHERE wallet=$3',
      [JSON.stringify(gameData), gameData.spiritStones, req.user.wallet]);
    const contribution = Math.floor(amount / 10);
    await pool.query('UPDATE sect_members SET contribution=contribution+$1 WHERE wallet=$2', [contribution, req.user.wallet]);
    await pool.query('UPDATE sects SET exp=exp+$1 WHERE id=$2', [amount, mem.rows[0].sect_id]);
    await checkSectLevelUp(mem.rows[0].sect_id);
    res.json({ ok: true, contribution, exp: amount });
  } catch (e) { res.status(500).json({ error: e.message }); }
});

// GET /api/sect/members
app.get('/api/sect/members', auth, async (req, res) => {
  try {
    const { sectId } = req.query;
    const id = sectId || (await pool.query('SELECT sect_id FROM sect_members WHERE wallet=$1', [req.user.wallet])).rows[0]?.sect_id;
    if (!id) return res.status(400).json({ error: '未指定宗门' });
    const members = await pool.query(
      `SELECT sm.wallet, sm.role, sm.contribution, sm.joined_at, p.name, p.level, p.realm, p.combat_power
       FROM sect_members sm LEFT JOIN players p ON sm.wallet = p.wallet WHERE sm.sect_id=$1 ORDER BY sm.role='leader' DESC, sm.role='elder' DESC, sm.contribution DESC`,
      [id]
    );
    res.json({ members: members.rows });
  } catch (e) { res.status(500).json({ error: e.message }); }
});

// === WebSocket 世界聊天 + 全服动态 ===
const server = createServer(app);
const wss = new WebSocketServer({ server, path: '/ws' });

const onlineClients = new Map(); // ws -> { wallet, name }
const recentMessages = []; // 最近50条聊天
const recentEvents = []; // 最近30条全服动态
const MAX_CHAT = 50;
const MAX_EVENTS = 30;
const CHAT_COOLDOWN = 3000; // 发言冷却3秒
const lastChatTime = new Map(); // wallet -> timestamp

// === PK 系统 ===
const pkChallenges = new Map(); // challengeId -> { from, to, fromStats, timestamp }
const pkCooldown = new Map(); // wallet -> timestamp
const PK_COOLDOWN_MS = 30000; // PK 冷却 30秒
const PK_REWARD = 500; // 胜者奖励灵石
let pkIdCounter = 0;

function getWsByWallet(wallet) {
  for (const [ws, info] of onlineClients) {
    if (info.wallet === wallet) return ws;
  }
  return null;
}

function runPkBattle(statsA, statsB) {
  // 简化版服务端战斗（复用前端 combat 逻辑）
  const calcDmg = (atk, def) => {
    let dmg = atk.attack * (100 / (100 + def.defense));
    let isCrit = Math.random() < (atk.critRate || 0.05);
    let isCombo = Math.random() < (atk.comboRate || 0);
    let isDodged = Math.random() < (def.dodgeRate || 0.05);
    if (isCrit) dmg *= 1.5 + (atk.critDamageBoost || 0);
    if (isCombo) dmg *= 1.3;
    dmg *= 1 - (def.finalDamageReduce || 0);
    return { damage: Math.floor(dmg), isCrit, isCombo, isDodged };
  };

  let hpA = statsA.health, hpB = statsB.health;
  const rounds = [];
  const maxRounds = 15;

  for (let i = 0; i < maxRounds && hpA > 0 && hpB > 0; i++) {
    const r = { round: i + 1, actions: [] };
    // A 先攻（速度高先手）
    const first = (statsA.speed || 10) >= (statsB.speed || 10) ? 'A' : 'B';
    const order = first === 'A' ? [['A', statsA, statsB], ['B', statsB, statsA]] : [['B', statsB, statsA], ['A', statsA, statsB]];

    for (const [side, atk, def] of order) {
      if ((side === 'A' ? hpA : hpB) <= 0) break;
      const hit = calcDmg(atk, def);
      if (hit.isDodged) {
        r.actions.push({ attacker: side, isDodged: true, damage: 0, isCrit: false, isCombo: false });
      } else {
        if (side === 'A') hpB = Math.max(0, hpB - hit.damage);
        else hpA = Math.max(0, hpA - hit.damage);
        r.actions.push({ attacker: side, damage: hit.damage, isCrit: hit.isCrit, isCombo: hit.isCombo, isDodged: false });
      }
      if (hpA <= 0 || hpB <= 0) break;
    }
    r.hpA = Math.max(0, hpA);
    r.hpB = Math.max(0, hpB);
    rounds.push(r);
  }

  const winner = hpA > hpB ? 'A' : hpB > hpA ? 'B' : 'draw';
  return { rounds, winner, finalHpA: Math.max(0, hpA), finalHpB: Math.max(0, hpB) };
}

function broadcast(data) {
  const msg = JSON.stringify(data);
  wss.clients.forEach(c => { if (c.readyState === 1) c.send(msg); });
}

// 全服动态广播（供 API 调用）
function broadcastEvent(text, type = 'info') {
  const evt = { type: 'event', text, eventType: type, time: Date.now() };
  recentEvents.push(evt);
  if (recentEvents.length > MAX_EVENTS) recentEvents.shift();
  broadcast(evt);
}


// 获取好友钱包列表（用于在线状态通知）
async function getFriendWallets(wallet) {
  try {
    const result = await pool.query(
      "SELECT from_wallet, to_wallet FROM friendships WHERE (from_wallet=$1 OR to_wallet=$1) AND status='accepted'",
      [wallet]
    );
    return result.rows.map(r => r.from_wallet === wallet ? r.to_wallet : r.from_wallet);
  } catch { return []; }
}

wss.on('connection', (ws, req) => {
  let userInfo = null;

  // 发送历史消息和动态
  ws.send(JSON.stringify({ type: 'init', messages: recentMessages, events: recentEvents, online: wss.clients.size }));

  ws.on('message', async (raw) => {
    try {
      const data = JSON.parse(raw);

      // 心跳
      if (data.type === 'ping') {
        ws.send(JSON.stringify({ type: 'pong' }));
        return;
      }

      // 认证
      if (data.type === 'auth') {
        try {
          const decoded = jwt.verify(data.token, JWT_SECRET);
          userInfo = { wallet: decoded.wallet, name: data.name || '无名修士' };
          onlineClients.set(ws, userInfo);
          broadcast({ type: 'online', count: wss.clients.size });
          broadcastEvent(`${userInfo.name} 进入了修仙界`, 'join');
          // 通知好友上线
          const friends = await getFriendWallets(userInfo.wallet);
          for (const fw of friends) {
            const fwWs = getWsByWallet(fw);
            if (fwWs) {
              fwWs.send(JSON.stringify({ type: 'friend_online', wallet: userInfo.wallet }));
            }
          }
        } catch { ws.send(JSON.stringify({ type: 'error', msg: '认证失败' })); }
        return;
      }

      // 聊天消息
      if (data.type === 'chat') {
        if (!userInfo) return ws.send(JSON.stringify({ type: 'error', msg: '请先登录' }));
        const text = (data.text || '').trim().slice(0, 200);
        if (!text) return;

        // 冷却检查
        const now = Date.now();
        const last = lastChatTime.get(userInfo.wallet) || 0;
        if (now - last < CHAT_COOLDOWN) {
          return ws.send(JSON.stringify({ type: 'error', msg: '发言太快，请稍后再试' }));
        }
        lastChatTime.set(userInfo.wallet, now);

        const msg = {
          type: 'chat',
          name: userInfo.name,
          wallet: userInfo.wallet.slice(0, 6) + '...' + userInfo.wallet.slice(-4),
          text,
          time: now
        };
        recentMessages.push(msg);
        if (recentMessages.length > MAX_CHAT) recentMessages.shift();
        broadcast(msg);
      }

      // === PK 消息处理 ===
      // 更新战斗数据
      if (data.type === 'pk_update_stats') {
        if (!userInfo) return;
        userInfo.stats = data.stats || {};
        userInfo.level = data.level || 1;
        userInfo.realm = data.realm || '练气一层';
        userInfo.combatPower = data.combatPower || 0;
        onlineClients.set(ws, userInfo);
      }

      // 获取在线玩家列表
      if (data.type === 'pk_get_players') {
        if (!userInfo) return;
        const players = [];
        for (const [, info] of onlineClients) {
          if (info.wallet !== userInfo.wallet) {
            players.push({
              wallet: info.wallet.slice(0, 6) + '...' + info.wallet.slice(-4),
              fullWallet: info.wallet,
              name: info.name,
              level: info.level || 1,
              realm: info.realm || '练气一层',
              combatPower: info.combatPower || 0
            });
          }
        }
        ws.send(JSON.stringify({ type: 'pk_players', players }));
      }

      // 发起挑战
      if (data.type === 'pk_challenge') {
        if (!userInfo) return;
        const now = Date.now();
        const lastPk = pkCooldown.get(userInfo.wallet) || 0;
        if (now - lastPk < PK_COOLDOWN_MS) {
          return ws.send(JSON.stringify({ type: 'pk_error', msg: `PK冷却中，${Math.ceil((PK_COOLDOWN_MS - (now - lastPk)) / 1000)}秒后再试` }));
        }
        const targetWs = getWsByWallet(data.targetWallet);
        if (!targetWs) return ws.send(JSON.stringify({ type: 'pk_error', msg: '对方已离线' }));

        const challengeId = ++pkIdCounter;
        pkChallenges.set(challengeId, {
          from: userInfo.wallet, to: data.targetWallet,
          fromName: userInfo.name, toName: onlineClients.get(targetWs)?.name || '无名修士',
          fromStats: userInfo.stats || {}, timestamp: now
        });
        // 30秒后自动过期
        setTimeout(() => pkChallenges.delete(challengeId), 30000);

        targetWs.send(JSON.stringify({
          type: 'pk_challenged', challengeId,
          from: userInfo.wallet.slice(0, 6) + '...' + userInfo.wallet.slice(-4),
          fromName: userInfo.name,
          fromLevel: userInfo.level || 1,
          fromCombatPower: userInfo.combatPower || 0
        }));
        ws.send(JSON.stringify({ type: 'pk_challenge_sent', challengeId }));
      }

      // 接受挑战
      if (data.type === 'pk_accept') {
        if (!userInfo) return;
        const challenge = pkChallenges.get(data.challengeId);
        if (!challenge || challenge.to !== userInfo.wallet) {
          return ws.send(JSON.stringify({ type: 'pk_error', msg: '挑战已过期' }));
        }
        pkChallenges.delete(data.challengeId);

        const fromWs = getWsByWallet(challenge.from);
        if (!fromWs) return ws.send(JSON.stringify({ type: 'pk_error', msg: '挑战者已离线' }));

        // 设置冷却
        pkCooldown.set(challenge.from, Date.now());
        pkCooldown.set(userInfo.wallet, Date.now());

        // 构造双方属性
        const statsA = {
          health: challenge.fromStats.health || 100,
          attack: challenge.fromStats.attack || 10,
          defense: challenge.fromStats.defense || 5,
          speed: challenge.fromStats.speed || 10,
          critRate: challenge.fromStats.critRate || 0.05,
          comboRate: challenge.fromStats.comboRate || 0,
          dodgeRate: challenge.fromStats.dodgeRate || 0.05,
          critDamageBoost: challenge.fromStats.critDamageBoost || 0,
          finalDamageReduce: challenge.fromStats.finalDamageReduce || 0,
        };
        const myStats = userInfo.stats || {};
        const statsB = {
          health: myStats.health || 100,
          attack: myStats.attack || 10,
          defense: myStats.defense || 5,
          speed: myStats.speed || 10,
          critRate: myStats.critRate || 0.05,
          comboRate: myStats.comboRate || 0,
          dodgeRate: myStats.dodgeRate || 0.05,
          critDamageBoost: myStats.critDamageBoost || 0,
          finalDamageReduce: myStats.finalDamageReduce || 0,
        };

        // 跑战斗
        const result = runPkBattle(statsA, statsB);
        const winnerWallet = result.winner === 'A' ? challenge.from : result.winner === 'B' ? userInfo.wallet : null;
        const winnerName = result.winner === 'A' ? challenge.fromName : result.winner === 'B' ? userInfo.name : null;

        // 发放奖励
        if (winnerWallet) {
          try {
            await pool.query(
              `UPDATE players SET spirit_stones = spirit_stones + $1,
               game_data = jsonb_set(game_data, '{spiritStones}', to_jsonb((COALESCE((game_data->>'spiritStones')::bigint, 0) + $1)::bigint))
               WHERE wallet = $2`,
              [PK_REWARD, winnerWallet]
            );
          } catch {}
          broadcastEvent(`${winnerName} 在切磋中击败了 ${result.winner === 'A' ? challenge.toName : challenge.fromName}，获得 ${PK_REWARD} 灵石！`, 'pk');
        }

        // 持久化 PK 记录
        try {
          await pool.query(
            `INSERT INTO pk_records (wallet_a, wallet_b, name_a, name_b, winner, winner_wallet, rounds_data, reward)
             VALUES ($1, $2, $3, $4, $5, $6, $7, $8)`,
            [challenge.from, userInfo.wallet, challenge.fromName, userInfo.name,
             result.winner, winnerWallet, JSON.stringify(result.rounds), winnerWallet ? PK_REWARD : 0]
          );
        } catch {}

        const battleResult = {
          type: 'pk_result',
          nameA: challenge.fromName, nameB: userInfo.name,
          walletA: challenge.from, walletB: userInfo.wallet,
          rounds: result.rounds, winner: result.winner,
          winnerName, reward: PK_REWARD,
          finalHpA: result.finalHpA, finalHpB: result.finalHpB,
          maxHpA: statsA.health, maxHpB: statsB.health
        };

        fromWs.send(JSON.stringify(battleResult));
        ws.send(JSON.stringify(battleResult));
      }

      
      // 私聊消息
      if (data.type === 'private_chat') {
        if (!userInfo) return;
        const text = (data.text || '').trim().slice(0, 500);
        if (!text || !data.toWallet) return;

        // 存DB
        await pool.query(
          'INSERT INTO private_messages (from_wallet, to_wallet, content) VALUES ($1, $2, $3)',
          [userInfo.wallet, data.toWallet, text]
        );

        // 实时推送给对方（如果在线）
        const targetWs = getWsByWallet(data.toWallet);
        const msgData = {
          type: 'private_chat',
          from: userInfo.wallet,
          fromName: userInfo.name,
          text,
          time: Date.now()
        };
        if (targetWs) targetWs.send(JSON.stringify(msgData));
        // 也回发给自己确认
        ws.send(JSON.stringify({ ...msgData, self: true }));
      }

      // 标记已读
      if (data.type === 'mark_read') {
        if (!userInfo || !data.fromWallet) return;
        await pool.query(
          'UPDATE private_messages SET is_read = true WHERE from_wallet = $1 AND to_wallet = $2 AND is_read = false',
          [data.fromWallet, userInfo.wallet]
        );
      }

      // 拒绝挑战
      if (data.type === 'pk_decline') {
        const challenge = pkChallenges.get(data.challengeId);
        if (challenge) {
          pkChallenges.delete(data.challengeId);
          const fromWs = getWsByWallet(challenge.from);
          if (fromWs) fromWs.send(JSON.stringify({ type: 'pk_declined', by: userInfo?.name || '对方' }));
        }
      }
    } catch {}
  });

  ws.on('close', async () => {
    if (userInfo) {
      onlineClients.delete(ws);
      broadcast({ type: 'online', count: wss.clients.size });
      // 通知好友离线
      const friends = await getFriendWallets(userInfo.wallet);
      for (const fw of friends) {
        const fwWs = getWsByWallet(fw);
        if (fwWs) {
          fwWs.send(JSON.stringify({ type: 'friend_offline', wallet: userInfo.wallet }));
        }
      }
    }
  });
});

// 暴露 broadcastEvent 给路由使用

// GET /api/friend/chat/:wallet - 获取与某好友的聊天记录
app.get('/api/friend/chat/:wallet', auth, async (req, res) => {
  try {
    const w = req.user.wallet;
    const other = req.params.wallet;
    const rows = await pool.query(
      `SELECT * FROM private_messages WHERE (from_wallet=$1 AND to_wallet=$2) OR (from_wallet=$2 AND to_wallet=$1) ORDER BY created_at DESC LIMIT 100`,
      [w, other]
    );
    // 标记为已读
    await pool.query(
      'UPDATE private_messages SET is_read=true WHERE from_wallet=$1 AND to_wallet=$2 AND is_read=false',
      [other, w]
    );
    res.json({ ok: true, messages: rows.rows.reverse() });
  } catch (e) { res.status(500).json({ error: e.message }); }
});

// GET /api/friend/unread - 获取未读消息计数（按发送者分组）
app.get('/api/friend/unread', auth, async (req, res) => {
  try {
    const rows = await pool.query(
      `SELECT from_wallet, COUNT(*)::int as count FROM private_messages WHERE to_wallet=$1 AND is_read=false GROUP BY from_wallet`,
      [req.user.wallet]
    );
    res.json({ ok: true, unread: rows.rows });
  } catch (e) { res.status(500).json({ error: e.message }); }
});

// === Admin 活动管理 ===
const adminAuth = async (req, res, next) => {
  if (!req.user) return res.status(401).json({ error: "未登录" });
  const adminWallet = "0xfad7eb0814b6838b05191a07fb987957d50c4ca9";
  if (req.user.wallet.toLowerCase() !== adminWallet) return res.status(403).json({ error: "无权限" });
  next();
};

// GET /api/admin/events - 获取所有活动
app.get("/api/admin/events", auth, adminAuth, async (req, res) => {
  try {
    const result = await pool.query("SELECT * FROM events ORDER BY created_at DESC");
    res.json({ events: result.rows });
  } catch (e) { res.status(500).json({ error: e.message }); }
});

// POST /api/admin/events - 创建活动
app.post("/api/admin/events", auth, adminAuth, async (req, res) => {
  try {
    const { name, description, type, config, starts_at, ends_at, rewards, active } = req.body;
    if (!name || !type || !starts_at || !ends_at) return res.status(400).json({ error: "缺少必填字段" });
    const result = await pool.query(
      `INSERT INTO events (name, description, type, config, starts_at, ends_at, rewards, active) VALUES ($1,$2,$3,$4,$5,$6,$7,$8) RETURNING *`,
      [name, description || "", type, config || {}, starts_at, ends_at, rewards || [], active !== false]
    );
    res.json({ event: result.rows[0] });
  } catch (e) { res.status(500).json({ error: e.message }); }
});

// PUT /api/admin/events/:id - 编辑活动
app.put("/api/admin/events/:id", auth, adminAuth, async (req, res) => {
  try {
    const { name, description, type, config, starts_at, ends_at, rewards, active } = req.body;
    const result = await pool.query(
      `UPDATE events SET name=COALESCE($1,name), description=COALESCE($2,description), type=COALESCE($3,type), config=COALESCE($4,config), starts_at=COALESCE($5,starts_at), ends_at=COALESCE($6,ends_at), rewards=COALESCE($7,rewards), active=COALESCE($8,active) WHERE id=$9 RETURNING *`,
      [name, description, type, config, starts_at, ends_at, rewards, active, req.params.id]
    );
    if (!result.rows.length) return res.status(404).json({ error: "活动不存在" });
    res.json({ event: result.rows[0] });
  } catch (e) { res.status(500).json({ error: e.message }); }
});

// DELETE /api/admin/events/:id - 删除活动
app.delete("/api/admin/events/:id", auth, adminAuth, async (req, res) => {
  try {
    await pool.query("DELETE FROM event_claims WHERE event_id=$1", [req.params.id]);
    const result = await pool.query("DELETE FROM events WHERE id=$1 RETURNING id", [req.params.id]);
    if (!result.rows.length) return res.status(404).json({ error: "活动不存在" });
    res.json({ ok: true });
  } catch (e) { res.status(500).json({ error: e.message }); }
});

// GET /api/admin/events/:id/claims - 查看领取记录
app.get("/api/admin/events/:id/claims", auth, adminAuth, async (req, res) => {
  try {
    const result = await pool.query(
      `SELECT ec.id, ec.wallet, ec.claimed_at, p.name FROM event_claims ec LEFT JOIN players p ON ec.wallet = p.wallet WHERE ec.event_id=$1 ORDER BY ec.claimed_at DESC`,
      [req.params.id]
    );
    res.json({ claims: result.rows });
  } catch (e) { res.status(500).json({ error: e.message }); }
});

// GET /api/admin/stats - 活动统计
app.get("/api/admin/stats", auth, adminAuth, async (req, res) => {
  try {
    const activeEvents = await pool.query("SELECT COUNT(*) FROM events WHERE active=TRUE AND starts_at<=NOW() AND ends_at>NOW()");
    const totalClaims = await pool.query("SELECT COUNT(*) FROM event_claims");
    const totalPlayers = await pool.query("SELECT COUNT(*) FROM players");
    res.json({
      activeEvents: parseInt(activeEvents.rows[0].count),
      totalClaims: parseInt(totalClaims.rows[0].count),
      totalPlayers: parseInt(totalPlayers.rows[0].count)
    });
  } catch (e) { res.status(500).json({ error: e.message }); }
});

app.locals.broadcastEvent = broadcastEvent;


// === 世界 Boss 系统 ===
const bossAttackCooldown = new Map(); // wallet -> timestamp

async function settleBossRewards(bossId) {
  try {
    const ranking = await pool.query(
      'SELECT wallet, player_name, damage FROM boss_damage_log WHERE boss_id = $1 ORDER BY damage DESC',
      [bossId]
    );
    const rows = ranking.rows;
    for (let i = 0; i < rows.length; i++) {
      const rank = i + 1;
      let stones = 1000;
      if (rank === 1) stones = 50000;
      else if (rank === 2) stones = 30000;
      else if (rank === 3) stones = 20000;
      else if (rank <= 10) stones = 10000;
      else if (rank <= 50) stones = 5000;
      await pool.query(
        'INSERT INTO boss_rewards (boss_id, wallet, rank, reward_stones) VALUES ($1, $2, $3, $4)',
        [bossId, rows[i].wallet, rank, stones]
      );
    }
    const boss = await pool.query('SELECT name FROM world_bosses WHERE id = $1', [bossId]);
    const topDamagers = rows.slice(0, 5).map((r, i) => ({
      rank: i + 1, name: r.player_name, damage: Number(r.damage)
    }));
    const killerName = rows.length > 0 ? rows[0].player_name : '无名修士';
    broadcast({ type: 'boss_dead', data: { bossName: boss.rows[0]?.name, killerName, topDamagers } });
    broadcastEvent(`🐉 世界Boss ${boss.rows[0]?.name} 已被击杀！最大功臣: ${killerName}`, 'boss');
  } catch (e) {
    console.error('Boss reward settlement error:', e);
  }
}

// GET /api/boss/current
app.get('/api/boss/current', auth, async (req, res) => {
  try {
    const boss = await pool.query(
      "SELECT * FROM world_bosses WHERE status = 'active' ORDER BY spawn_time DESC LIMIT 1"
    );
    if (boss.rows.length === 0) return res.json({ boss: null });
    const b = boss.rows[0];
    const myDmg = await pool.query(
      'SELECT damage, attacks_count FROM boss_damage_log WHERE boss_id = $1 AND wallet = $2',
      [b.id, req.user.wallet]
    );
    const myRank = await pool.query(
      'SELECT COUNT(*) + 1 as rank FROM boss_damage_log WHERE boss_id = $1 AND damage > COALESCE((SELECT damage FROM boss_damage_log WHERE boss_id = $1 AND wallet = $2), 0)',
      [b.id, req.user.wallet]
    );
    const totalPlayers = await pool.query(
      'SELECT COUNT(*) FROM boss_damage_log WHERE boss_id = $1', [b.id]
    );
    res.json({
      boss: {
        id: b.id, name: b.name, level: b.level,
        maxHp: Number(b.max_hp), currentHp: Number(b.current_hp),
        attack: b.attack, defense: b.defense,
        description: b.description, status: b.status,
        rewardsConfig: b.rewards_config, spawnTime: b.spawn_time
      },
      myDamage: myDmg.rows[0] ? Number(myDmg.rows[0].damage) : 0,
      myAttacks: myDmg.rows[0] ? myDmg.rows[0].attacks_count : 0,
      myRank: myDmg.rows[0] ? parseInt(myRank.rows[0].rank) : 0,
      totalPlayers: parseInt(totalPlayers.rows[0].count)
    });
  } catch (e) { res.status(500).json({ error: e.message }); }
});

// POST /api/boss/attack
app.post('/api/boss/attack', auth, async (req, res) => {
  try {
    const wallet = req.user.wallet;
    const now = Date.now();
    const lastAtk = bossAttackCooldown.get(wallet) || 0;
    if (now - lastAtk < 3000) {
      return res.status(400).json({ error: `冷却中，${Math.ceil((3000 - (now - lastAtk)) / 1000)}秒后再试` });
    }
    const boss = await pool.query(
      "SELECT * FROM world_bosses WHERE status = 'active' ORDER BY spawn_time DESC LIMIT 1"
    );
    if (boss.rows.length === 0) return res.status(400).json({ error: '当前没有世界Boss' });
    const b = boss.rows[0];
    if (Number(b.current_hp) <= 0) return res.status(400).json({ error: 'Boss已被击杀' });
    const player = await pool.query('SELECT * FROM players WHERE wallet = $1', [wallet]);
    if (!player.rows.length) return res.status(400).json({ error: '玩家不存在' });
    const p = player.rows[0];
    const gameData = typeof p.game_data === 'string' ? JSON.parse(p.game_data) : (p.game_data || {});
    const spirit = gameData.spirit || 0;
    if (spirit < 10) return res.status(400).json({ error: '灵力不足，需要10灵力' });
    gameData.spirit = spirit - 10;
    await pool.query('UPDATE players SET game_data = $1 WHERE wallet = $2', [JSON.stringify(gameData), wallet]);
    // 计算装备加成
    let equipAtk = 0, equipCritRate = 0;
    if (gameData.equippedArtifacts) {
      Object.values(gameData.equippedArtifacts).forEach(eq => {
        if (!eq) return;
        const s = eq.stats || eq;
        equipAtk += (s.attack || 0);
        equipCritRate += (s.critRate || 0);
      });
    }
    // 查询坐骑+称号百分比加成
    let mountAtkPct = 0, titleAtkPct = 0;
    try {
      const mRow = await pool.query(
        `SELECT m.attack_bonus FROM player_mounts pm JOIN mounts m ON pm.mount_id=m.id WHERE pm.wallet=$1 AND pm.is_active=true`, [wallet]);
      if (mRow.rows[0]) mountAtkPct = mRow.rows[0].attack_bonus || 0;
      const tRow = await pool.query(
        `SELECT t.attack_bonus FROM player_titles pt JOIN titles t ON pt.title_id=t.id WHERE pt.wallet=$1 AND pt.is_active=true`, [wallet]);
      if (tRow.rows[0]) titleAtkPct = tRow.rows[0].attack_bonus || 0;
    } catch(e) {}
    const rawAtk = (gameData.baseAttributes?.attack || 100) + equipAtk;
    const pAtk = Math.floor(rawAtk * (1 + mountAtkPct + titleAtkPct));
    const critRate = Math.min(1, (gameData.combatAttributes?.critRate || 0.05) + equipCritRate);
    const isCrit = Math.random() < critRate;
    let damage = Math.max(1, Math.floor(pAtk * (100 / (100 + b.defense)) * (0.9 + Math.random() * 0.2)));
    if (isCrit) damage = Math.floor(damage * 1.5);
    const newHp = Math.max(0, Number(b.current_hp) - damage);
    await pool.query('UPDATE world_bosses SET current_hp = $1 WHERE id = $2', [newHp, b.id]);
    await pool.query(
      `INSERT INTO boss_damage_log (boss_id, wallet, player_name, damage, attacks_count, last_attack_at)
       VALUES ($1, $2, $3, $4, 1, NOW())
       ON CONFLICT (boss_id, wallet) DO UPDATE SET
         damage = boss_damage_log.damage + $4,
         attacks_count = boss_damage_log.attacks_count + 1,
         player_name = $3,
         last_attack_at = NOW()`,
      [b.id, wallet, p.name || '无名修士', damage]
    );
    bossAttackCooldown.set(wallet, now);
    const myTotal = await pool.query(
      'SELECT damage FROM boss_damage_log WHERE boss_id = $1 AND wallet = $2', [b.id, wallet]
    );
    broadcast({
      type: 'boss_hit',
      data: {
        playerName: p.name || '无名修士',
        damage, isCrit,
        bossHp: newHp, bossMaxHp: Number(b.max_hp)
      }
    });
    if (newHp <= 0) {
      await pool.query("UPDATE world_bosses SET status = 'dead', death_time = NOW() WHERE id = $1", [b.id]);
      await settleBossRewards(b.id);
    }
    res.json({
      damage, isCrit,
      bossHp: newHp, bossMaxHp: Number(b.max_hp),
      myTotalDamage: Number(myTotal.rows[0]?.damage || damage),
      spirit: gameData.spirit
    });
  } catch (e) { res.status(500).json({ error: e.message }); }
});

// GET /api/boss/ranking
app.get('/api/boss/ranking', auth, async (req, res) => {
  try {
    const boss = await pool.query(
      "SELECT id FROM world_bosses WHERE status = 'active' ORDER BY spawn_time DESC LIMIT 1"
    );
    if (boss.rows.length === 0) return res.json({ ranking: [] });
    const bossId = boss.rows[0].id;
    const result = await pool.query(
      'SELECT wallet, player_name, damage, attacks_count FROM boss_damage_log WHERE boss_id = $1 ORDER BY damage DESC LIMIT 50', [bossId]
    );
    const ranking = result.rows.map((r, i) => ({
      rank: i + 1,
      name: r.player_name,
      wallet: r.wallet.slice(0, 6) + '...' + r.wallet.slice(-4),
      fullWallet: r.wallet,
      damage: Number(r.damage),
      attacks: r.attacks_count
    }));
    res.json({ ranking });
  } catch (e) { res.status(500).json({ error: e.message }); }
});

// GET /api/boss/rewards
app.get('/api/boss/rewards', auth, async (req, res) => {
  try {
    const result = await pool.query(
      `SELECT br.*, wb.name as boss_name FROM boss_rewards br
       LEFT JOIN world_bosses wb ON br.boss_id = wb.id
       WHERE br.wallet = $1 ORDER BY br.created_at DESC`, [req.user.wallet]
    );
    res.json({ rewards: result.rows.map(r => ({
      id: r.id, bossId: r.boss_id, bossName: r.boss_name,
      rank: r.rank, stones: r.reward_stones, items: r.reward_items,
      claimed: r.claimed, createdAt: r.created_at
    })) });
  } catch (e) { res.status(500).json({ error: e.message }); }
});

// POST /api/boss/rewards/claim
app.post('/api/boss/rewards/claim', auth, async (req, res) => {
  try {
    const unclaimed = await pool.query(
      'SELECT * FROM boss_rewards WHERE wallet = $1 AND claimed = FALSE', [req.user.wallet]
    );
    if (unclaimed.rows.length === 0) return res.status(400).json({ error: '没有可领取的奖励' });
    let totalStones = 0;
    for (const r of unclaimed.rows) {
      totalStones += r.reward_stones;
      await pool.query('UPDATE boss_rewards SET claimed = TRUE WHERE id = $1', [r.id]);
    }
    const player = await pool.query('SELECT game_data FROM players WHERE wallet = $1', [req.user.wallet]);
    const gameData = typeof player.rows[0].game_data === 'string' ? JSON.parse(player.rows[0].game_data) : (player.rows[0].game_data || {});
    gameData.spiritStones = (gameData.spiritStones || 0) + totalStones;
    await pool.query('UPDATE players SET game_data = $1, spirit_stones = $2 WHERE wallet = $3',
      [JSON.stringify(gameData), gameData.spiritStones, req.user.wallet]);
    res.json({ ok: true, totalStones, newSpiritStones: gameData.spiritStones });
  } catch (e) { res.status(500).json({ error: e.message }); }
});

// GET /api/boss/history
app.get('/api/boss/history', auth, async (req, res) => {
  try {
    const result = await pool.query(
      'SELECT id, name, level, max_hp, attack, defense, status, spawn_time, death_time FROM world_bosses ORDER BY created_at DESC LIMIT 20'
    );
    res.json({ bosses: result.rows.map(r => ({
      id: r.id, name: r.name, level: r.level, maxHp: Number(r.max_hp),
      attack: r.attack, defense: r.defense, status: r.status,
      spawnTime: r.spawn_time, deathTime: r.death_time
    })) });
  } catch (e) { res.status(500).json({ error: e.message }); }
});

// POST /api/admin/boss/spawn
app.post('/api/admin/boss/spawn', auth, adminAuth, async (req, res) => {
  try {
    const { name, level, max_hp, attack, defense, description, rewards_config } = req.body;
    if (!name || !max_hp) return res.status(400).json({ error: '缺少必填字段' });
    await pool.query("UPDATE world_bosses SET status = 'dead', death_time = NOW() WHERE status = 'active'");
    const result = await pool.query(
      `INSERT INTO world_bosses (name, level, max_hp, current_hp, attack, defense, description, rewards_config, status, spawn_time)
       VALUES ($1,$2,$3,$3,$4,$5,$6,$7,'active',NOW()) RETURNING *`,
      [name, level || 100, max_hp, attack || 5000, defense || 2000, description || '', JSON.stringify(rewards_config || {})]
    );
    const b = result.rows[0];
    broadcast({ type: 'boss_spawn', data: { bossName: b.name, level: b.level, maxHp: Number(b.max_hp) } });
    broadcastEvent(`🐉 世界Boss【${b.name}】降临了！全体修士准备讨伐！`, 'boss');
    res.json({ ok: true, boss: b });
  } catch (e) { res.status(500).json({ error: e.message }); }
});

// GET /api/admin/boss/list
app.get('/api/admin/boss/list', auth, adminAuth, async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM world_bosses ORDER BY created_at DESC');
    res.json({ bosses: result.rows });
  } catch (e) { res.status(500).json({ error: e.message }); }
});

// POST /api/friend/accept - 接受好友申请
app.post("/api/friend/accept", auth, async (req, res) => {
  try {
    const { friendship_id } = req.body;
    if (!friendship_id) return res.status(400).json({ error: "缺少参数" });
    const f = await pool.query(`SELECT * FROM friendships WHERE id=$1 AND to_wallet=$2 AND status=$3`, [friendship_id, req.user.wallet, "pending"]);
    if (!f.rows.length) return res.status(404).json({ error: "申请不存在" });
    const countRes = await pool.query(`SELECT COUNT(*) FROM friendships WHERE (from_wallet=$1 OR to_wallet=$1) AND status=$2`, [req.user.wallet, "accepted"]);
    if (parseInt(countRes.rows[0].count) >= 50) return res.status(400).json({ error: "好友数量已达上限(50)" });
    await pool.query(`UPDATE friendships SET status=$1, updated_at=NOW() WHERE id=$2`, ["accepted", friendship_id]);
    res.json({ ok: true, message: "已接受好友申请" });
  } catch (e) { res.status(500).json({ error: e.message }); }
});

// POST /api/friend/reject - 拒绝好友申请
app.post("/api/friend/reject", auth, async (req, res) => {
  try {
    const { friendship_id } = req.body;
    if (!friendship_id) return res.status(400).json({ error: "缺少参数" });
    const f = await pool.query(`SELECT * FROM friendships WHERE id=$1 AND to_wallet=$2 AND status=$3`, [friendship_id, req.user.wallet, "pending"]);
    if (!f.rows.length) return res.status(404).json({ error: "申请不存在" });
    await pool.query(`UPDATE friendships SET status=$1, updated_at=NOW() WHERE id=$2`, ["rejected", friendship_id]);
    res.json({ ok: true, message: "已拒绝好友申请" });
  } catch (e) { res.status(500).json({ error: e.message }); }
});

// POST /api/friend/remove - 删除好友
app.post("/api/friend/remove", auth, async (req, res) => {
  try {
    const { wallet } = req.body;
    if (!wallet) return res.status(400).json({ error: "缺少参数" });
    const result = await pool.query(
      `DELETE FROM friendships WHERE ((from_wallet=$1 AND to_wallet=$2) OR (from_wallet=$2 AND to_wallet=$1)) AND status=$3`,
      [req.user.wallet, wallet, "accepted"]
    );
    if (result.rowCount === 0) return res.status(404).json({ error: "好友关系不存在" });
    res.json({ ok: true, message: "已删除好友" });
  } catch (e) { res.status(500).json({ error: e.message }); }
});

// GET /api/friend/profile/:wallet - 好友详情
app.get("/api/friend/profile/:wallet", auth, async (req, res) => {
  try {
    const w = req.user.wallet;
    const tw = req.params.wallet;
    const isFriend = await pool.query(
      `SELECT id FROM friendships WHERE ((from_wallet=$1 AND to_wallet=$2) OR (from_wallet=$2 AND to_wallet=$1)) AND status=$3`,
      [w, tw, "accepted"]
    );
    if (!isFriend.rows.length) return res.status(403).json({ error: "不是好友关系" });
    const p = await pool.query(`SELECT wallet, name, level, realm, combat_power, game_data, vip_level FROM players WHERE wallet=$1`, [tw]);
    if (!p.rows.length) return res.status(404).json({ error: "玩家不存在" });
    const player = p.rows[0];
    const gd = typeof player.game_data === "string" ? JSON.parse(player.game_data) : (player.game_data || {});
    const equippedArtifacts = gd.equippedArtifacts || {};
    const sect = await pool.query(
      `SELECT s.name as sect_name, sm.role FROM sect_members sm JOIN sects s ON s.id=sm.sect_id WHERE sm.wallet=$1`, [tw]
    );
    res.json({ ok: true, profile: {
      wallet: player.wallet, name: player.name || "无名修士", level: player.level || 1,
      realm: player.realm || "燃火期一层", combatPower: Number(player.combat_power || 0),
      vipLevel: player.vip_level || 0, equippedArtifacts,
      sect: sect.rows.length ? { name: sect.rows[0].sect_name, role: sect.rows[0].role } : null
    }});
  } catch (e) { res.status(500).json({ error: e.message }); }
});
// POST /api/friend/gift - 送礼
app.post("/api/friend/gift", auth, async (req, res) => {
  try {
    const { to_wallet, gift_type, gift_value, message: msg } = req.body;
    const w = req.user.wallet;
    if (!to_wallet || !gift_type || !gift_value) return res.status(400).json({ error: "缺少参数" });
    if (gift_value <= 0 || gift_value > 100000) return res.status(400).json({ error: "礼物数量无效(1-100000)" });
    const isFriend = await pool.query(
      `SELECT id FROM friendships WHERE ((from_wallet=$1 AND to_wallet=$2) OR (from_wallet=$2 AND to_wallet=$1)) AND status=$3`,
      [w, to_wallet, "accepted"]
    );
    if (!isFriend.rows.length) return res.status(403).json({ error: "不是好友关系" });
    const todayStart = new Date(); todayStart.setHours(0,0,0,0);
    const giftCount = await pool.query(
      `SELECT COUNT(*) FROM friend_gifts WHERE from_wallet=$1 AND created_at >= $2`, [w, todayStart]
    );
    if (parseInt(giftCount.rows[0].count) >= 3) return res.status(400).json({ error: "今日送礼次数已用完(3/3)" });
    if (gift_type === "spirit_stones") {
      const player = await pool.query(`SELECT spirit_stones, game_data FROM players WHERE wallet=$1`, [w]);
      if (!player.rows.length) return res.status(404).json({ error: "玩家不存在" });
      const gd = typeof player.rows[0].game_data === "string" ? JSON.parse(player.rows[0].game_data) : (player.rows[0].game_data || {});
      const stones = gd.spiritStones ?? player.rows[0].spirit_stones ?? 0;
      if (stones < gift_value) return res.status(400).json({ error: "灵石不足" });
      gd.spiritStones = (gd.spiritStones || 0) - gift_value;
      await pool.query(`UPDATE players SET game_data=$1, spirit_stones=$2 WHERE wallet=$3`,
        [JSON.stringify(gd), gd.spiritStones, w]);
    }
    await pool.query(
      `INSERT INTO friend_gifts (from_wallet, to_wallet, gift_type, gift_value, message) VALUES ($1,$2,$3,$4,$5)`,
      [w, to_wallet, gift_type, gift_value, msg || ""]
    );
    const remaining = 3 - parseInt(giftCount.rows[0].count) - 1;
    res.json({ ok: true, message: "礼物已送出", remaining });
  } catch (e) { res.status(500).json({ error: e.message }); }
});

// GET /api/friend/gifts - 收到的礼物列表
app.get("/api/friend/gifts", auth, async (req, res) => {
  try {
    const result = await pool.query(
      `SELECT g.id, g.from_wallet, g.gift_type, g.gift_value, g.message, g.claimed, g.created_at, p.name
       FROM friend_gifts g JOIN players p ON p.wallet=g.from_wallet
       WHERE g.to_wallet=$1 ORDER BY g.claimed ASC, g.created_at DESC LIMIT 50`,
      [req.user.wallet]
    );
    res.json({ ok: true, gifts: result.rows.map(r => ({
      id: r.id, fromWallet: r.from_wallet, fromName: r.name || "无名修士",
      giftType: r.gift_type, giftValue: r.gift_value, message: r.message,
      claimed: r.claimed, createdAt: r.created_at
    })) });
  } catch (e) { res.status(500).json({ error: e.message }); }
});

// POST /api/friend/gifts/:id/claim - 领取礼物
app.post("/api/friend/gifts/:id/claim", auth, async (req, res) => {
  try {
    const giftId = req.params.id;
    if (!giftId || isNaN(parseInt(giftId))) return res.status(400).json({ error: "无效的礼物ID" });
    const g = await pool.query(`SELECT * FROM friend_gifts WHERE id=$1 AND to_wallet=$2 AND claimed=FALSE`, [giftId, req.user.wallet]);
    if (!g.rows.length) return res.status(404).json({ error: "礼物不存在或已领取" });
    const gift = g.rows[0];
    if (gift.gift_type === "spirit_stones") {
      const player = await pool.query(`SELECT game_data FROM players WHERE wallet=$1`, [req.user.wallet]);
      const gd = typeof player.rows[0].game_data === "string" ? JSON.parse(player.rows[0].game_data) : (player.rows[0].game_data || {});
      gd.spiritStones = (gd.spiritStones || 0) + gift.gift_value;
      await pool.query(`UPDATE players SET game_data=$1, spirit_stones=$2 WHERE wallet=$3`,
        [JSON.stringify(gd), gd.spiritStones, req.user.wallet]);
    }
    await pool.query(`UPDATE friend_gifts SET claimed=TRUE WHERE id=$1`, [giftId]);
    res.json({ ok: true, message: "礼物已领取", giftType: gift.gift_type, giftValue: gift.gift_value });
  } catch (e) { res.status(500).json({ error: e.message }); }
});
// ============ 好友系统 API ============

// GET /api/friend/list - 好友列表
app.get("/api/friend/list", auth, async (req, res) => {
  try {
    const w = req.user.wallet;
    const result = await pool.query(
      `SELECT f.id as friendship_id, 
        CASE WHEN f.from_wallet=$1 THEN f.to_wallet ELSE f.from_wallet END as friend_wallet,
        p.name, p.level, p.realm, p.combat_power, p.updated_at
       FROM friendships f
       JOIN players p ON p.wallet = CASE WHEN f.from_wallet=$1 THEN f.to_wallet ELSE f.from_wallet END
       WHERE (f.from_wallet=$1 OR f.to_wallet=$1) AND f.status=$2
       ORDER BY p.combat_power DESC`,
      [w, "accepted"]
    );
    const now = Date.now();
    const friends = result.rows.map(r => ({
      friendshipId: r.friendship_id,
      wallet: r.friend_wallet,
      name: r.name || "无名修士",
      level: r.level || 1,
      realm: r.realm || "燃火期一层",
      combatPower: Number(r.combat_power || 0),
      online: r.updated_at ? (now - new Date(r.updated_at).getTime() < 5 * 60 * 1000) : false
    }));
    res.json({ ok: true, friends, count: friends.length, max: 50 });
  } catch (e) { res.status(500).json({ error: e.message }); }
});

// GET /api/friend/requests - 收到的好友申请
app.get("/api/friend/requests", auth, async (req, res) => {
  try {
    const result = await pool.query(
      `SELECT f.id, f.from_wallet, f.created_at, p.name, p.level, p.realm, p.combat_power
       FROM friendships f JOIN players p ON p.wallet=f.from_wallet
       WHERE f.to_wallet=$1 AND f.status=$2 ORDER BY f.created_at DESC`,
      [req.user.wallet, "pending"]
    );
    res.json({ ok: true, requests: result.rows.map(r => ({
      id: r.id, wallet: r.from_wallet, name: r.name || "无名修士",
      level: r.level || 1, realm: r.realm || "燃火期一层",
      combatPower: Number(r.combat_power || 0), createdAt: r.created_at
    })) });
  } catch (e) { res.status(500).json({ error: e.message }); }
});

// POST /api/friend/search - 搜索玩家
app.post("/api/friend/search", auth, async (req, res) => {
  try {
    const { keyword } = req.body;
    if (!keyword || keyword.trim().length < 1) return res.status(400).json({ error: "请输入搜索关键词" });
    const result = await pool.query(
      `SELECT wallet, name, level, realm, combat_power FROM players
       WHERE name ILIKE $1 AND wallet != $2 LIMIT 20`,
      ["%" + keyword.trim() + "%", req.user.wallet]
    );
    const friendsRes = await pool.query(
      `SELECT CASE WHEN from_wallet=$1 THEN to_wallet ELSE from_wallet END as fw
       FROM friendships WHERE (from_wallet=$1 OR to_wallet=$1) AND status IN ($2,$3)`,
      [req.user.wallet, "accepted", "pending"]
    );
    const friendSet = new Set(friendsRes.rows.map(r => r.fw));
    res.json({ ok: true, players: result.rows.map(r => ({
      wallet: r.wallet, name: r.name || "无名修士", level: r.level || 1,
      realm: r.realm || "燃火期一层", combatPower: Number(r.combat_power || 0),
      isFriend: friendSet.has(r.wallet)
    })) });
  } catch (e) { res.status(500).json({ error: e.message }); }
});

// POST /api/friend/add - 发送好友申请
app.post("/api/friend/add", auth, async (req, res) => {
  try {
    const { to_wallet } = req.body;
    const w = req.user.wallet;
    if (!to_wallet) return res.status(400).json({ error: "缺少参数" });
    if (to_wallet.toLowerCase() === w.toLowerCase()) return res.status(400).json({ error: "不能添加自己" });
    const countRes = await pool.query(
      `SELECT COUNT(*) FROM friendships WHERE (from_wallet=$1 OR to_wallet=$1) AND status=$2`,
      [w, "accepted"]
    );
    if (parseInt(countRes.rows[0].count) >= 50) return res.status(400).json({ error: "好友数量已达上限(50)" });
    const existing = await pool.query(
      `SELECT id, status FROM friendships WHERE
       ((from_wallet=$1 AND to_wallet=$2) OR (from_wallet=$2 AND to_wallet=$1))`,
      [w, to_wallet]
    );
    if (existing.rows.length > 0) {
      const s = existing.rows[0].status;
      if (s === "accepted") return res.status(400).json({ error: "已经是好友了" });
      if (s === "pending") return res.status(400).json({ error: "已发送过申请，请等待对方处理" });
      if (s === "rejected") {
        await pool.query(`UPDATE friendships SET status=$1, from_wallet=$2, to_wallet=$3, updated_at=NOW() WHERE id=$4`,
          ["pending", w, to_wallet, existing.rows[0].id]);
        return res.json({ ok: true, message: "好友申请已发送" });
      }
    }
    await pool.query(`INSERT INTO friendships (from_wallet, to_wallet, status) VALUES ($1,$2,$3)`, [w, to_wallet, "pending"]);
    res.json({ ok: true, message: "好友申请已发送" });
  } catch (e) { res.status(500).json({ error: e.message }); }
});

// ============ 宗门战系统 ============

// POST /api/sect-war/challenge - 发起宗门战
app.post('/api/sect-war/challenge', auth, async (req, res) => {
  try {
    const { defender_sect_id } = req.body;
    const w = req.user.wallet;
    if (!defender_sect_id) return res.status(400).json({ error: '缺少参数' });

    // 检查身份：掌门或长老
    const mem = await pool.query('SELECT sect_id, role FROM sect_members WHERE wallet=$1', [w]);
    if (!mem.rows.length) return res.status(400).json({ error: '你还没有加入宗门' });
    const { sect_id, role } = mem.rows[0];
    if (role !== 'leader' && role !== 'elder') return res.status(400).json({ error: '只有掌门或长老才能发起宗门战' });

    if (sect_id === defender_sect_id) return res.status(400).json({ error: '不能挑战自己的宗门' });

    // 对方宗门至少3人
    const defCount = await pool.query('SELECT COUNT(*) FROM sect_members WHERE sect_id=$1', [defender_sect_id]);
    if (parseInt(defCount.rows[0].count) < 3) return res.status(400).json({ error: '对方宗门人数不足3人，无法挑战' });

    // 己方宗门至少3人
    const myCount = await pool.query('SELECT COUNT(*) FROM sect_members WHERE sect_id=$1', [sect_id]);
    if (parseInt(myCount.rows[0].count) < 3) return res.status(400).json({ error: '本宗门人数不足3人，无法发起挑战' });

    // 每天最多3次
    const today = new Date(); today.setHours(0,0,0,0);
    const dailyCount = await pool.query(
      'SELECT COUNT(*) FROM sect_wars WHERE challenger_sect_id=$1 AND created_at >= $2',
      [sect_id, today]
    );
    if (parseInt(dailyCount.rows[0].count) >= 3) return res.status(400).json({ error: '今日挑战次数已用完(3/3)' });

    // 检查是否有进行中的宗门战
    const ongoing = await pool.query(
      "SELECT id FROM sect_wars WHERE (challenger_sect_id=$1 OR defender_sect_id=$1) AND status IN ('pending','in_progress')",
      [sect_id]
    );
    if (ongoing.rows.length > 0) return res.status(400).json({ error: '你的宗门已有进行中的宗门战' });

    const defOngoing = await pool.query(
      "SELECT id FROM sect_wars WHERE (challenger_sect_id=$1 OR defender_sect_id=$1) AND status IN ('pending','in_progress')",
      [defender_sect_id]
    );
    if (defOngoing.rows.length > 0) return res.status(400).json({ error: '对方宗门已有进行中的宗门战' });

    const war = await pool.query(
      'INSERT INTO sect_wars (challenger_sect_id, defender_sect_id, status) VALUES ($1,$2,$3) RETURNING *',
      [sect_id, defender_sect_id, 'pending']
    );
    res.json({ ok: true, war: war.rows[0] });
  } catch (e) { res.status(500).json({ error: e.message }); }
});

// GET /api/sect-war/pending - 收到的宗门战邀请
app.get('/api/sect-war/pending', auth, async (req, res) => {
  try {
    const mem = await pool.query('SELECT sect_id, role FROM sect_members WHERE wallet=$1', [req.user.wallet]);
    if (!mem.rows.length) return res.json({ wars: [] });
    const { sect_id } = mem.rows[0];
    const wars = await pool.query(
      `SELECT sw.*, cs.name as challenger_name, ds.name as defender_name,
        (SELECT COUNT(*) FROM sect_members WHERE sect_id=sw.challenger_sect_id) as challenger_members
       FROM sect_wars sw
       JOIN sects cs ON sw.challenger_sect_id=cs.id
       JOIN sects ds ON sw.defender_sect_id=ds.id
       WHERE sw.defender_sect_id=$1 AND sw.status='pending'
       ORDER BY sw.created_at DESC`,
      [sect_id]
    );
    res.json({ wars: wars.rows });
  } catch (e) { res.status(500).json({ error: e.message }); }
});

// POST /api/sect-war/accept - 接受宗门战
app.post('/api/sect-war/accept', auth, async (req, res) => {
  try {
    const { war_id } = req.body;
    const mem = await pool.query('SELECT sect_id, role FROM sect_members WHERE wallet=$1', [req.user.wallet]);
    if (!mem.rows.length) return res.status(400).json({ error: '你还没有加入宗门' });
    if (mem.rows[0].role !== 'leader' && mem.rows[0].role !== 'elder')
      return res.status(400).json({ error: '只有掌门或长老才能接受挑战' });

    const war = await pool.query('SELECT * FROM sect_wars WHERE id=$1 AND status=$2', [war_id, 'pending']);
    if (!war.rows.length) return res.status(400).json({ error: '宗门战不存在或已处理' });
    if (war.rows[0].defender_sect_id !== mem.rows[0].sect_id)
      return res.status(400).json({ error: '这不是你宗门收到的挑战' });

    await pool.query("UPDATE sect_wars SET status='in_progress', started_at=NOW() WHERE id=$1", [war_id]);
    res.json({ ok: true, message: '已接受挑战，宗门战开始！' });
  } catch (e) { res.status(500).json({ error: e.message }); }
});

// POST /api/sect-war/decline - 拒绝宗门战
app.post('/api/sect-war/decline', auth, async (req, res) => {
  try {
    const { war_id } = req.body;
    const mem = await pool.query('SELECT sect_id, role FROM sect_members WHERE wallet=$1', [req.user.wallet]);
    if (!mem.rows.length) return res.status(400).json({ error: '你还没有加入宗门' });
    if (mem.rows[0].role !== 'leader' && mem.rows[0].role !== 'elder')
      return res.status(400).json({ error: '只有掌门或长老才能拒绝挑战' });

    const war = await pool.query('SELECT * FROM sect_wars WHERE id=$1 AND status=$2', [war_id, 'pending']);
    if (!war.rows.length) return res.status(400).json({ error: '宗门战不存在或已处理' });
    if (war.rows[0].defender_sect_id !== mem.rows[0].sect_id)
      return res.status(400).json({ error: '这不是你宗门收到的挑战' });

    await pool.query("UPDATE sect_wars SET status='finished', finished_at=NOW() WHERE id=$1", [war_id]);
    res.json({ ok: true, message: '已拒绝挑战' });
  } catch (e) { res.status(500).json({ error: e.message }); }
});

// POST /api/sect-war/join - 报名参战
app.post('/api/sect-war/join', auth, async (req, res) => {
  try {
    const { war_id } = req.body;
    const w = req.user.wallet;
    const mem = await pool.query('SELECT sect_id FROM sect_members WHERE wallet=$1', [w]);
    if (!mem.rows.length) return res.status(400).json({ error: '你还没有加入宗门' });
    const mySectId = mem.rows[0].sect_id;

    const war = await pool.query("SELECT * FROM sect_wars WHERE id=$1 AND status='in_progress'", [war_id]);
    if (!war.rows.length) return res.status(400).json({ error: '宗门战不存在或未开始' });

    const warData = war.rows[0];
    if (mySectId !== warData.challenger_sect_id && mySectId !== warData.defender_sect_id)
      return res.status(400).json({ error: '你的宗门不在这场宗门战中' });

    // 检查是否已报名
    const existing = await pool.query('SELECT id FROM sect_war_participants WHERE war_id=$1 AND wallet=$2', [war_id, w]);
    if (existing.rows.length) return res.status(400).json({ error: '你已经报名了' });

    // 每方最多5人
    const count = await pool.query('SELECT COUNT(*) FROM sect_war_participants WHERE war_id=$1 AND sect_id=$2', [war_id, mySectId]);
    if (parseInt(count.rows[0].count) >= 5) return res.status(400).json({ error: '本方参战名额已满(5/5)' });

    // 检查是否已有rounds_data（战斗已开始）
    if (warData.rounds_data) return res.status(400).json({ error: '战斗已经开始，无法报名' });

    const player = await pool.query('SELECT name, combat_power FROM players WHERE wallet=$1', [w]);
    const pName = player.rows[0]?.name || '无名修士';
    const cp = parseInt(player.rows[0]?.combat_power || 0);

    await pool.query(
      'INSERT INTO sect_war_participants (war_id, sect_id, wallet, player_name, combat_power) VALUES ($1,$2,$3,$4,$5)',
      [war_id, mySectId, w, pName, cp]
    );
    res.json({ ok: true, message: '报名成功！' });
  } catch (e) { res.status(500).json({ error: e.message }); }
});

// POST /api/sect-war/start - 开始战斗
app.post('/api/sect-war/start', auth, async (req, res) => {
  try {
    const { war_id } = req.body;
    const w = req.user.wallet;
    const mem = await pool.query('SELECT sect_id, role FROM sect_members WHERE wallet=$1', [w]);
    if (!mem.rows.length) return res.status(400).json({ error: '你还没有加入宗门' });
    if (mem.rows[0].role !== 'leader') return res.status(400).json({ error: '只有掌门才能开始战斗' });

    const war = await pool.query("SELECT * FROM sect_wars WHERE id=$1 AND status='in_progress'", [war_id]);
    if (!war.rows.length) return res.status(400).json({ error: '宗门战不存在或状态不对' });
    const warData = war.rows[0];

    if (warData.challenger_sect_id !== mem.rows[0].sect_id && warData.defender_sect_id !== mem.rows[0].sect_id)
      return res.status(400).json({ error: '你不在这场宗门战中' });
    if (warData.rounds_data) return res.status(400).json({ error: '战斗已经开始过了' });

    // 获取双方参战人员
    const challengers = await pool.query(
      'SELECT * FROM sect_war_participants WHERE war_id=$1 AND sect_id=$2 ORDER BY combat_power DESC',
      [war_id, warData.challenger_sect_id]
    );
    const defenders = await pool.query(
      'SELECT * FROM sect_war_participants WHERE war_id=$1 AND sect_id=$2 ORDER BY combat_power DESC',
      [war_id, warData.defender_sect_id]
    );

    if (!challengers.rows.length || !defenders.rows.length)
      return res.status(400).json({ error: '双方都需要有人报名才能开始' });

    const rounds = Math.min(5, challengers.rows.length, defenders.rows.length);
    const roundsData = [];
    let cScore = 0, dScore = 0;

    for (let i = 0; i < rounds; i++) {
      const c = challengers.rows[i];
      const d = defenders.rows[i];
      const cPower = Number(c.combat_power) || 1;
      const dPower = Number(d.combat_power) || 1;

      // 胜率公式
      const cWinRate = (cPower / (cPower + dPower)) * 0.7 + Math.random() * 0.3;
      const cWin = cWinRate > 0.5;

      const round = {
        round: i + 1,
        challenger: { wallet: c.wallet, name: c.player_name, combat_power: cPower, win: cWin },
        defender: { wallet: d.wallet, name: d.player_name, combat_power: dPower, win: !cWin }
      };
      roundsData.push(round);

      if (cWin) { cScore++; } else { dScore++; }

      // 更新参战者结果
      await pool.query('UPDATE sect_war_participants SET result=$1, round_number=$2, damage_dealt=$3 WHERE id=$4',
        [cWin ? 'win' : 'lose', i + 1, cPower, c.id]);
      await pool.query('UPDATE sect_war_participants SET result=$1, round_number=$2, damage_dealt=$3 WHERE id=$4',
        [cWin ? 'lose' : 'win', i + 1, dPower, d.id]);
    }

    const winnerSectId = cScore > dScore ? warData.challenger_sect_id :
                         dScore > cScore ? warData.defender_sect_id : null;
    const loserSectId = winnerSectId === warData.challenger_sect_id ? warData.defender_sect_id :
                        winnerSectId === warData.defender_sect_id ? warData.challenger_sect_id : null;

    await pool.query(
      "UPDATE sect_wars SET status='finished', challenger_score=$1, defender_score=$2, winner_sect_id=$3, rounds_data=$4, finished_at=NOW() WHERE id=$5",
      [cScore, dScore, winnerSectId, JSON.stringify(roundsData), war_id]
    );

    // 发放奖励
    const allParticipants = await pool.query('SELECT * FROM sect_war_participants WHERE war_id=$1', [war_id]);
    for (const p of allParticipants.rows) {
      const isWinner = winnerSectId && p.sect_id === winnerSectId;
      const stones = isWinner ? 5000 : (winnerSectId ? 1000 : 2000);
      const contrib = isWinner ? 100 : (winnerSectId ? 20 : 50);
      await pool.query(
        'INSERT INTO sect_war_rewards (war_id, sect_id, wallet, reward_stones, reward_contribution) VALUES ($1,$2,$3,$4,$5)',
        [war_id, p.sect_id, p.wallet, stones, contrib]
      );
    }

    // 更新排行榜
    if (winnerSectId) {
      // 胜方: +3积分, +500经验
      const wr = await pool.query('SELECT id FROM sect_war_rankings WHERE sect_id=$1 AND season=1', [winnerSectId]);
      if (wr.rows.length) {
        await pool.query('UPDATE sect_war_rankings SET wins=wins+1, points=points+3, updated_at=NOW() WHERE sect_id=$1 AND season=1', [winnerSectId]);
      } else {
        await pool.query('INSERT INTO sect_war_rankings (sect_id, season, wins, points) VALUES ($1,1,1,3)', [winnerSectId]);
      }
      await pool.query('UPDATE sects SET exp=exp+500 WHERE id=$1', [winnerSectId]);
      await checkSectLevelUp(winnerSectId);

      // 败方: +1积分
      const lr = await pool.query('SELECT id FROM sect_war_rankings WHERE sect_id=$1 AND season=1', [loserSectId]);
      if (lr.rows.length) {
        await pool.query('UPDATE sect_war_rankings SET losses=losses+1, points=points+1, updated_at=NOW() WHERE sect_id=$1 AND season=1', [loserSectId]);
      } else {
        await pool.query('INSERT INTO sect_war_rankings (sect_id, season, losses, points) VALUES ($1,1,1,1)', [loserSectId]);
      }
    } else {
      // 平局：双方各+1
      for (const sid of [warData.challenger_sect_id, warData.defender_sect_id]) {
        const r = await pool.query('SELECT id FROM sect_war_rankings WHERE sect_id=$1 AND season=1', [sid]);
        if (r.rows.length) {
          await pool.query('UPDATE sect_war_rankings SET points=points+1, updated_at=NOW() WHERE sect_id=$1 AND season=1', [sid]);
        } else {
          await pool.query('INSERT INTO sect_war_rankings (sect_id, season, points) VALUES ($1,1,1)', [sid]);
        }
      }
    }

    res.json({ ok: true, rounds: roundsData, challenger_score: cScore, defender_score: dScore, winner_sect_id: winnerSectId });
  } catch (e) { res.status(500).json({ error: e.message }); }
});

// GET /api/sect-war/current - 当前进行中的宗门战
app.get('/api/sect-war/current', auth, async (req, res) => {
  try {
    const mem = await pool.query('SELECT sect_id FROM sect_members WHERE wallet=$1', [req.user.wallet]);
    if (!mem.rows.length) return res.json({ war: null });
    const sid = mem.rows[0].sect_id;

    const war = await pool.query(
      `SELECT sw.*, cs.name as challenger_name, ds.name as defender_name
       FROM sect_wars sw
       JOIN sects cs ON sw.challenger_sect_id=cs.id
       JOIN sects ds ON sw.defender_sect_id=ds.id
       WHERE (sw.challenger_sect_id=$1 OR sw.defender_sect_id=$1) AND sw.status IN ('pending','in_progress')
       ORDER BY sw.created_at DESC LIMIT 1`,
      [sid]
    );
    if (!war.rows.length) return res.json({ war: null });

    const participants = await pool.query(
      `SELECT swp.*, p.name as current_name FROM sect_war_participants swp
       LEFT JOIN players p ON swp.wallet=p.wallet
       WHERE swp.war_id=$1 ORDER BY swp.combat_power DESC`,
      [war.rows[0].id]
    );

    res.json({ war: war.rows[0], participants: participants.rows, mySectId: sid });
  } catch (e) { res.status(500).json({ error: e.message }); }
});

// GET /api/sect-war/history - 宗门战历史
app.get('/api/sect-war/history', auth, async (req, res) => {
  try {
    const mem = await pool.query('SELECT sect_id FROM sect_members WHERE wallet=$1', [req.user.wallet]);
    if (!mem.rows.length) return res.json({ wars: [] });
    const sid = mem.rows[0].sect_id;

    const wars = await pool.query(
      `SELECT sw.*, cs.name as challenger_name, ds.name as defender_name
       FROM sect_wars sw
       JOIN sects cs ON sw.challenger_sect_id=cs.id
       JOIN sects ds ON sw.defender_sect_id=ds.id
       WHERE (sw.challenger_sect_id=$1 OR sw.defender_sect_id=$1) AND sw.status='finished' AND sw.rounds_data IS NOT NULL
       ORDER BY sw.finished_at DESC LIMIT 20`,
      [sid]
    );
    res.json({ wars: wars.rows, mySectId: sid });
  } catch (e) { res.status(500).json({ error: e.message }); }
});

// GET /api/sect-war/ranking - 排行榜
app.get('/api/sect-war/ranking', auth, async (req, res) => {
  try {
    const rankings = await pool.query(
      `SELECT swr.*, s.name as sect_name, s.level as sect_level
       FROM sect_war_rankings swr
       JOIN sects s ON swr.sect_id=s.id
       WHERE swr.season=1
       ORDER BY swr.points DESC, swr.wins DESC LIMIT 50`
    );
    res.json({ rankings: rankings.rows });
  } catch (e) { res.status(500).json({ error: e.message }); }
});

// GET /api/sect-war/rewards - 我的奖励
app.get('/api/sect-war/rewards', auth, async (req, res) => {
  try {
    const rewards = await pool.query(
      `SELECT swr.*, sw.challenger_sect_id, sw.defender_sect_id, cs.name as challenger_name, ds.name as defender_name
       FROM sect_war_rewards swr
       JOIN sect_wars sw ON swr.war_id=sw.id
       JOIN sects cs ON sw.challenger_sect_id=cs.id
       JOIN sects ds ON sw.defender_sect_id=ds.id
       WHERE swr.wallet=$1
       ORDER BY swr.created_at DESC LIMIT 20`,
      [req.user.wallet]
    );
    res.json({ rewards: rewards.rows });
  } catch (e) { res.status(500).json({ error: e.message }); }
});

// POST /api/sect-war/rewards/claim - 领取奖励
app.post('/api/sect-war/rewards/claim', auth, async (req, res) => {
  try {
    const w = req.user.wallet;
    const unclaimed = await pool.query(
      'SELECT * FROM sect_war_rewards WHERE wallet=$1 AND claimed=false', [w]
    );
    if (!unclaimed.rows.length) return res.status(400).json({ error: '没有可领取的奖励' });

    let totalStones = 0, totalContrib = 0;
    for (const r of unclaimed.rows) {
      totalStones += r.reward_stones;
      totalContrib += r.reward_contribution;
    }

    await pool.query('UPDATE sect_war_rewards SET claimed=true WHERE wallet=$1 AND claimed=false', [w]);
    await pool.query(
      `UPDATE players SET spirit_stones = spirit_stones + $1,
       game_data = jsonb_set(game_data, '{spiritStones}', to_jsonb((COALESCE((game_data->>'spiritStones')::bigint, 0) + $1)::bigint))
       WHERE wallet=$2`,
      [totalStones, w]
    );

    // 更新宗门贡献
    const mem = await pool.query('SELECT sect_id FROM sect_members WHERE wallet=$1', [w]);
    if (mem.rows.length) {
      await pool.query('UPDATE sect_members SET contribution = contribution + $1 WHERE wallet=$2', [totalContrib, w]);
    }

    res.json({ ok: true, stones: totalStones, contribution: totalContrib, message: `领取了 ${totalStones} 灵石和 ${totalContrib} 贡献度` });
  } catch (e) { res.status(500).json({ error: e.message }); }
});

// ============ 宗门战系统结束 ============

// ============ 拍卖行系统 ============

// 过期处理函数
async function processExpiredAuctions() {
  try {
    const expired = await pool.query(
      "SELECT * FROM auction_listings WHERE status='active' AND expires_at < NOW()"
    );
    for (const listing of expired.rows) {
      if (listing.current_bid > 0 && listing.current_bidder) {
        // 有出价：物品给最高出价者，灵石给卖家（扣5%手续费）
        const fee = Math.floor(listing.current_bid * 0.05);
        const sellerGets = listing.current_bid - fee;
        // 物品给买家
        await pool.query(
          `UPDATE players SET game_data = jsonb_set(game_data, '{items}', COALESCE(game_data->'items', '[]'::jsonb) || $1::jsonb) WHERE wallet = $2`,
          [JSON.stringify([listing.item_data]), listing.current_bidder]
        );
        // 灵石给卖家
        await pool.query(
          `UPDATE players SET game_data = jsonb_set(game_data, '{spiritStones}', to_jsonb(GREATEST(0, (COALESCE(game_data->>'spiritStones','0'))::int + $1))),
           spirit_stones = spirit_stones + $1 WHERE wallet = $2`,
          [sellerGets, listing.seller_wallet]
        );
        await pool.query("UPDATE auction_listings SET status='sold' WHERE id=$1", [listing.id]);
        await pool.query(
          "INSERT INTO auction_history (listing_id, seller_wallet, buyer_wallet, item_name, item_type, item_quality, final_price) VALUES ($1,$2,$3,$4,$5,$6,$7)",
          [listing.id, listing.seller_wallet, listing.current_bidder, listing.item_name, listing.item_type, listing.item_quality, listing.current_bid]
        );
      } else {
        // 无出价：物品退回卖家
        await pool.query(
          `UPDATE players SET game_data = jsonb_set(game_data, '{items}', COALESCE(game_data->'items', '[]'::jsonb) || $1::jsonb) WHERE wallet = $2`,
          [JSON.stringify([listing.item_data]), listing.seller_wallet]
        );
        await pool.query("UPDATE auction_listings SET status='expired' WHERE id=$1", [listing.id]);
      }
    }
  } catch (e) { console.error('processExpiredAuctions error:', e.message); }
}

// POST /api/auction/list - 上架物品
app.post('/api/auction/list', auth, async (req, res) => {
  try {
    const w = req.user.wallet;
    const { item_id, starting_price, buyout_price, duration_hours } = req.body;
    if (!item_id || !starting_price || !duration_hours) return res.status(400).json({ error: '参数缺失' });
    if (![12, 24, 48].includes(duration_hours)) return res.status(400).json({ error: '持续时间只能是12/24/48小时' });
    if (starting_price < 1) return res.status(400).json({ error: '起拍价至少为1' });
    if (buyout_price && buyout_price <= starting_price) return res.status(400).json({ error: '一口价必须高于起拍价' });

    // 检查上架数量限制
    const countRes = await pool.query("SELECT COUNT(*) FROM auction_listings WHERE seller_wallet=$1 AND status='active'", [w]);
    if (parseInt(countRes.rows[0].count) >= 10) return res.status(400).json({ error: '最多同时上架10件物品' });

    const player = await pool.query('SELECT game_data, name FROM players WHERE wallet=$1', [w]);
    if (!player.rows.length) return res.status(404).json({ error: '玩家不存在' });
    const gd = player.rows[0].game_data;
    const playerName = player.rows[0].name || '无名修士';
    const items = gd.items || [];
    const itemIndex = items.findIndex(i => i.id === item_id);
    if (itemIndex === -1) return res.status(400).json({ error: '物品不存在' });

    const item = items[itemIndex];

    // 检查是否已装备
    const equipped = gd.equippedArtifacts || {};
    const equippedIds = Object.values(equipped).filter(Boolean).map(e => e.id);
    if (equippedIds.includes(item_id)) return res.status(400).json({ error: '已装备的物品不能上架' });

    // 上架费 5%
    const listingFee = Math.max(1, Math.floor(starting_price * 0.05));
    const stones = parseInt(gd.spiritStones) || 0;
    if (stones < listingFee) return res.status(400).json({ error: `灵石不足，上架费需要 ${listingFee} 灵石` });

    // 扣灵石 + 移除物品
    items.splice(itemIndex, 1);
    const newStones = stones - listingFee;
    const newGd = { ...gd, items, spiritStones: newStones };
    await pool.query('UPDATE players SET game_data=$1, spirit_stones=$2 WHERE wallet=$3', [JSON.stringify(newGd), newStones, w]);

    const quality = item.quality || item.rarity || 'common';
    const expiresAt = new Date(Date.now() + duration_hours * 3600000);
    await pool.query(
      `INSERT INTO auction_listings (seller_wallet, seller_name, item_data, item_name, item_type, item_quality, starting_price, buyout_price, duration_hours, expires_at)
       VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10)`,
      [w, playerName, JSON.stringify(item), item.name, item.type, quality, starting_price, buyout_price || null, duration_hours, expiresAt]
    );

    res.json({ ok: true, message: `${item.name} 已上架，扣除上架费 ${listingFee} 灵石`, spiritStones: newStones });
  } catch (e) { res.status(500).json({ error: e.message }); }
});

// GET /api/auction/browse - 浏览拍卖行
app.get('/api/auction/browse', auth, async (req, res) => {
  try {
    await processExpiredAuctions();
    const { type, quality, sort, page = 1, limit = 12 } = req.query;
    let where = "status='active' AND expires_at > NOW()";
    const params = [];
    let idx = 1;
    if (type) { where += ` AND item_type=$${idx++}`; params.push(type); }
    if (quality) { where += ` AND item_quality=$${idx++}`; params.push(quality); }

    let orderBy = 'created_at DESC';
    if (sort === 'price_asc') orderBy = 'GREATEST(current_bid, starting_price) ASC';
    else if (sort === 'price_desc') orderBy = 'GREATEST(current_bid, starting_price) DESC';
    else if (sort === 'time_asc') orderBy = 'expires_at ASC';
    else if (sort === 'time_desc') orderBy = 'expires_at DESC';

    const offset = (parseInt(page) - 1) * parseInt(limit);
    const countQ = await pool.query(`SELECT COUNT(*) FROM auction_listings WHERE ${where}`, params);
    const total = parseInt(countQ.rows[0].count);
    const listings = await pool.query(
      `SELECT id, seller_name, item_data, item_name, item_type, item_quality, starting_price, buyout_price, current_bid, bid_count, expires_at, created_at
       FROM auction_listings WHERE ${where} ORDER BY ${orderBy} LIMIT $${idx++} OFFSET $${idx++}`,
      [...params, parseInt(limit), offset]
    );
    res.json({ listings: listings.rows, total, page: parseInt(page), limit: parseInt(limit) });
  } catch (e) { res.status(500).json({ error: e.message }); }
});

// GET /api/auction/detail/:id - 拍卖详情
app.get('/api/auction/detail/:id', auth, async (req, res) => {
  try {
    if (!req.params.id || isNaN(parseInt(req.params.id))) return res.status(400).json({ error: '无效的拍卖ID' });
    await processExpiredAuctions();
    const listing = await pool.query('SELECT * FROM auction_listings WHERE id=$1', [req.params.id]);
    if (!listing.rows.length) return res.status(404).json({ error: '拍卖不存在' });
    const bids = await pool.query('SELECT bidder_name, bid_amount, created_at FROM auction_bids WHERE listing_id=$1 ORDER BY bid_amount DESC LIMIT 20', [req.params.id]);
    res.json({ listing: listing.rows[0], bids: bids.rows });
  } catch (e) { res.status(500).json({ error: e.message }); }
});

// POST /api/auction/bid - 出价
app.post('/api/auction/bid', auth, async (req, res) => {
  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    const w = req.user.wallet;
    const { listing_id, amount } = req.body;
    if (!listing_id || !amount) { await client.query('ROLLBACK'); return res.status(400).json({ error: '参数缺失' }); }

    const listing = await client.query("SELECT * FROM auction_listings WHERE id=$1 AND status='active' AND expires_at > NOW() FOR UPDATE", [listing_id]);
    if (!listing.rows.length) { await client.query('ROLLBACK'); return res.status(400).json({ error: '拍卖不存在或已结束' }); }
    const l = listing.rows[0];
    if (l.seller_wallet === w) { await client.query('ROLLBACK'); return res.status(400).json({ error: '不能对自己的物品出价' }); }

    const minBid = l.current_bid > 0 ? Math.ceil(l.current_bid * 1.1) : l.starting_price;
    if (amount < minBid) { await client.query('ROLLBACK'); return res.status(400).json({ error: `出价至少为 ${minBid} 灵石` }); }

    const player = await client.query('SELECT game_data FROM players WHERE wallet=$1 FOR UPDATE', [w]);
    const gd = player.rows[0].game_data;
    const stones = parseInt(gd.spiritStones) || 0;
    if (stones < amount) { await client.query('ROLLBACK'); return res.status(400).json({ error: '灵石不足' }); }

    const playerNameRes = await client.query('SELECT name FROM players WHERE wallet=$1', [w]);
    const bidderName = playerNameRes.rows[0]?.name || '无名修士';

    // 退还上一个出价者
    if (l.current_bidder && l.current_bid > 0) {
      await client.query(
        `UPDATE players SET game_data = jsonb_set(game_data, '{spiritStones}', to_jsonb(GREATEST(0, (COALESCE(game_data->>'spiritStones','0'))::int + $1))),
         spirit_stones = spirit_stones + $1 WHERE wallet = $2`,
        [l.current_bid, l.current_bidder]
      );
    }

    // 扣除出价者灵石
    await client.query(
      `UPDATE players SET game_data = jsonb_set(game_data, '{spiritStones}', to_jsonb(GREATEST(0, (COALESCE(game_data->>'spiritStones','0'))::int - $1))),
       spirit_stones = spirit_stones - $1 WHERE wallet = $2`,
      [amount, w]
    );

    // 更新拍卖
    await client.query(
      'UPDATE auction_listings SET current_bid=$1, current_bidder=$2, bid_count=bid_count+1 WHERE id=$3',
      [amount, w, listing_id]
    );
    await client.query(
      'INSERT INTO auction_bids (listing_id, bidder_wallet, bidder_name, bid_amount) VALUES ($1,$2,$3,$4)',
      [listing_id, w, bidderName, amount]
    );

    await client.query('COMMIT');
    res.json({ ok: true, message: `出价 ${amount} 灵石成功` });
  } catch (e) { await client.query('ROLLBACK'); res.status(500).json({ error: e.message }); }
  finally { client.release(); }
});





// === 焰兽升级 (消耗精华, game_data.items) ===
app.put('/api/pets/:id/upgrade', auth, async (req, res) => {
  try {
    const petId = req.params.id;
    const wallet = req.user.wallet;
    const result = await pool.query('SELECT game_data FROM players WHERE wallet = $1', [wallet]);
    if (!result.rows.length) return res.status(404).json({ success: false, message: '玩家不存在' });
    const gameData = typeof result.rows[0].game_data === 'string' ? JSON.parse(result.rows[0].game_data) : (result.rows[0].game_data || {});
    const petIndex = (gameData.items || []).findIndex(i => String(i.id) === String(petId) && i.type === 'pet');
    if (petIndex === -1) return res.status(404).json({ success: false, message: '焰兽不存在' });
    const pet = gameData.items[petIndex];
    const level = pet.level || 1;
    const cost = level * 10;
    if ((gameData.petEssence || 0) < cost) return res.status(400).json({ success: false, message: `焰兽精华不足，需要${cost}` });
    gameData.petEssence -= cost;
    pet.level = level + 1;
    const qm = { divine: 2.0, celestial: 1.8, mystic: 1.6, spiritual: 1.4, mortal: 1.2 }[pet.rarity] || 1.2;
    const attrs = pet.combatAttributes || {};
    for (const [k, v] of Object.entries(attrs)) {
      if (typeof v === 'number') {
        attrs[k] = v < 1 ? Math.round((v + 0.01 * qm) * 1000) / 1000 : Math.floor(v * (1 + 0.01 * qm));
      }
    }
    pet.combatAttributes = attrs;
    await pool.query('UPDATE players SET game_data = $1 WHERE wallet = $2', [JSON.stringify(gameData), wallet]);
    res.json({ success: true, data: pet });
  } catch (err) { console.error('Upgrade pet error:', err); res.status(500).json({ success: false, message: '服务器错误' }); }
});

// === 焰兽出战 (game_data) ===
app.put('/api/pets/:id/deploy', auth, async (req, res) => {
  try {
    const petId = req.params.id;
    const wallet = req.user.wallet;
    const result = await pool.query('SELECT game_data FROM players WHERE wallet = $1', [wallet]);
    if (!result.rows.length) return res.status(404).json({ success: false, message: '玩家不存在' });
    const gameData = typeof result.rows[0].game_data === 'string' ? JSON.parse(result.rows[0].game_data) : (result.rows[0].game_data || {});
    const pet = (gameData.items || []).find(i => String(i.id) === String(petId) && i.type === 'pet');
    if (!pet) return res.status(404).json({ success: false, message: '焰兽不存在' });
    // Recall current active pet
    (gameData.items || []).forEach(i => { if (i.type === 'pet') i.is_active = false; });
    pet.is_active = true;
    gameData.activePetId = petId;
    await pool.query('UPDATE players SET game_data = $1 WHERE wallet = $2', [JSON.stringify(gameData), wallet]);
    res.json({ success: true, data: pet });
  } catch (err) { console.error('Deploy pet error:', err); res.status(500).json({ success: false, message: '服务器错误' }); }
});

// === 焰兽召回 (game_data) ===
app.put('/api/pets/:id/recall', auth, async (req, res) => {
  try {
    const petId = req.params.id;
    const wallet = req.user.wallet;
    const result = await pool.query('SELECT game_data FROM players WHERE wallet = $1', [wallet]);
    if (!result.rows.length) return res.status(404).json({ success: false, message: '玩家不存在' });
    const gameData = typeof result.rows[0].game_data === 'string' ? JSON.parse(result.rows[0].game_data) : (result.rows[0].game_data || {});
    const pet = (gameData.items || []).find(i => String(i.id) === String(petId) && i.type === 'pet');
    if (!pet) return res.status(404).json({ success: false, message: '焰兽不存在' });
    pet.is_active = false;
    if (String(gameData.activePetId) === String(petId)) gameData.activePetId = null;
    await pool.query('UPDATE players SET game_data = $1 WHERE wallet = $2', [JSON.stringify(gameData), wallet]);
    res.json({ success: true, data: pet });
  } catch (err) { console.error('Recall pet error:', err); res.status(500).json({ success: false, message: '服务器错误' }); }
});

// === 获取焰兽列表 (game_data.items) ===
app.get('/api/pets', auth, async (req, res) => {
  try {
    const wallet = req.user.wallet;
    const result = await pool.query('SELECT game_data FROM players WHERE wallet = $1', [wallet]);
    if (!result.rows.length) return res.json({ success: true, data: [] });
    
    const gameData = typeof result.rows[0].game_data === 'string' 
      ? JSON.parse(result.rows[0].game_data) 
      : (result.rows[0].game_data || {});
    
    const pets = (gameData.items || []).filter(i => i.type === 'pet');
    res.json({ success: true, data: pets });
  } catch (err) {
    console.error('Get pets error:', err);
    res.status(500).json({ success: false, message: '服务器错误' });
  }
});

// === 焰兽升星 (game_data.items) ===
app.put('/api/pets/:id/evolve', auth, async (req, res) => {
  try {
    const petId = req.params.id;
    const { foodPetId } = req.body;
    const wallet = req.user.wallet;
    const result = await pool.query('SELECT game_data FROM players WHERE wallet = $1', [wallet]);
    if (!result.rows.length) return res.status(404).json({ success: false, message: '玩家不存在' });
    
    const gameData = typeof result.rows[0].game_data === 'string' 
      ? JSON.parse(result.rows[0].game_data) 
      : (result.rows[0].game_data || {});
    
    if (!gameData.items) return res.status(404).json({ success: false, message: '焰兽不存在' });
    
    const petIndex = gameData.items.findIndex(i => String(i.id) === String(petId) && i.type === 'pet');
    if (petIndex === -1) return res.status(404).json({ success: false, message: '焰兽不存在' });
    
    const foodIndex = gameData.items.findIndex(i => String(i.id) === String(foodPetId) && i.type === 'pet');
    if (foodIndex === -1) return res.status(404).json({ success: false, message: '素材焰兽不存在' });
    
    const pet = gameData.items[petIndex];
    const food = gameData.items[foodIndex];
    
    if (pet.rarity !== food.rarity || pet.name !== food.name) {
      return res.status(400).json({ success: false, message: '只能使用相同品质和名字的焰兽进行升星' });
    }
    
    if ((pet.star || 0) >= 10) {
      return res.status(400).json({ success: false, message: '已达最高星级' });
    }
    
    // Remove food pet first
    gameData.items.splice(foodIndex, 1);
    // Recalc pet index after splice
    const newPetIndex = gameData.items.findIndex(i => String(i.id) === String(petId) && i.type === 'pet');
    gameData.items[newPetIndex].star = (gameData.items[newPetIndex].star || 0) + 1;
    
    // Return essence from food pet level
    const returnEssence = ((food.level || 1) - 1) * 10;
    if (returnEssence > 0) gameData.petEssence = (gameData.petEssence || 0) + returnEssence;
    
    // Boost combat attributes by 15%
    const attrs = gameData.items[newPetIndex].combatAttributes || gameData.items[newPetIndex].combat_attributes || {};
    const boosted = {};
    for (const [key, val] of Object.entries(attrs)) {
      if (typeof val === 'number') {
        boosted[key] = val < 1 ? Math.round((val * 1.15) * 1000) / 1000 : Math.round(val * 1.15);
      } else {
        boosted[key] = val;
      }
    }
    gameData.items[newPetIndex].combatAttributes = boosted;
    
    await pool.query('UPDATE players SET game_data = $1 WHERE wallet = $2', 
      [JSON.stringify(gameData), wallet]);
    
    res.json({ success: true, data: gameData.items[newPetIndex] });
  } catch (err) {
    console.error('Evolve pet error:', err);
    res.status(500).json({ success: false, message: '服务器错误' });
  }
});

// === 放生焰兽 (game_data.items) ===
app.delete('/api/pets/:id/release', auth, async (req, res) => {
  try {
    const petId = req.params.id;
    const wallet = req.user.wallet;
    const result = await pool.query('SELECT game_data FROM players WHERE wallet = $1', [wallet]);
    if (!result.rows.length) return res.status(404).json({ success: false, message: '玩家不存在' });
    
    const gameData = typeof result.rows[0].game_data === 'string' 
      ? JSON.parse(result.rows[0].game_data) 
      : (result.rows[0].game_data || {});
    
    if (!gameData.items) return res.status(404).json({ success: false, message: '焰兽不存在' });
    
    const petIndex = gameData.items.findIndex(i => String(i.id) === String(petId) && i.type === 'pet');
    if (petIndex === -1) return res.status(404).json({ success: false, message: '焰兽不存在' });
    
    const pet = gameData.items[petIndex];
    const essenceReward = { divine: 50, celestial: 30, mystic: 20, spiritual: 10, mortal: 5 };
    const essence = essenceReward[pet.rarity] || 5;
    
    gameData.items.splice(petIndex, 1);
    gameData.petEssence = (gameData.petEssence || 0) + essence;
    
    await pool.query('UPDATE players SET game_data = $1 WHERE wallet = $2', 
      [JSON.stringify(gameData), wallet]);
    
    res.json({ success: true, data: { essenceGained: essence } });
  } catch (err) {
    console.error('Release pet error:', err);
    res.status(500).json({ success: false, message: '服务器错误' });
  }
});

// POST /api/auction/buyout - 一口价购买
app.post('/api/auction/buyout', auth, async (req, res) => {
  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    const w = req.user.wallet;
    const { listing_id } = req.body;
    if (!listing_id) { await client.query('ROLLBACK'); return res.status(400).json({ error: '参数缺失' }); }

    const listing = await client.query("SELECT * FROM auction_listings WHERE id=$1 AND status='active' AND expires_at > NOW() FOR UPDATE", [listing_id]);
    if (!listing.rows.length) { await client.query('ROLLBACK'); return res.status(400).json({ error: '拍卖不存在或已结束' }); }
    const l = listing.rows[0];
    if (!l.buyout_price) { await client.query('ROLLBACK'); return res.status(400).json({ error: '该拍卖没有一口价' }); }
    if (l.seller_wallet === w) { await client.query('ROLLBACK'); return res.status(400).json({ error: '不能购买自己的物品' }); }

    const player = await client.query('SELECT game_data FROM players WHERE wallet=$1 FOR UPDATE', [w]);
    const gd = player.rows[0].game_data;
    const stones = parseInt(gd.spiritStones) || 0;
    if (stones < l.buyout_price) { await client.query('ROLLBACK'); return res.status(400).json({ error: '灵石不足' }); }

    // 退还之前的出价者
    if (l.current_bidder && l.current_bid > 0) {
      await client.query(
        `UPDATE players SET game_data = jsonb_set(game_data, '{spiritStones}', to_jsonb(GREATEST(0, (COALESCE(game_data->>'spiritStones','0'))::int + $1))),
         spirit_stones = spirit_stones + $1 WHERE wallet = $2`,
        [l.current_bid, l.current_bidder]
      );
    }

    // 扣除买家灵石
    await client.query(
      `UPDATE players SET game_data = jsonb_set(game_data, '{spiritStones}', to_jsonb(GREATEST(0, (COALESCE(game_data->>'spiritStones','0'))::int - $1))),
       spirit_stones = spirit_stones - $1 WHERE wallet = $2`,
      [l.buyout_price, w]
    );

    // 物品给买家
    await client.query(
      `UPDATE players SET game_data = jsonb_set(game_data, '{items}', COALESCE(game_data->'items', '[]'::jsonb) || $1::jsonb) WHERE wallet = $2`,
      [JSON.stringify([l.item_data]), w]
    );

    // 灵石给卖家（扣5%手续费）
    const fee = Math.floor(l.buyout_price * 0.05);
    const sellerGets = l.buyout_price - fee;
    await client.query(
      `UPDATE players SET game_data = jsonb_set(game_data, '{spiritStones}', to_jsonb(GREATEST(0, (COALESCE(game_data->>'spiritStones','0'))::int + $1))),
       spirit_stones = spirit_stones + $1 WHERE wallet = $2`,
      [sellerGets, l.seller_wallet]
    );

    // 更新拍卖状态
    await client.query("UPDATE auction_listings SET status='sold', current_bid=$1, current_bidder=$2 WHERE id=$3", [l.buyout_price, w, listing_id]);
    await client.query(
      "INSERT INTO auction_history (listing_id, seller_wallet, buyer_wallet, item_name, item_type, item_quality, final_price) VALUES ($1,$2,$3,$4,$5,$6,$7)",
      [listing_id, l.seller_wallet, w, l.item_name, l.item_type, l.item_quality, l.buyout_price]
    );

    await client.query('COMMIT');
    res.json({ ok: true, message: `成功购买 ${l.item_name}，花费 ${l.buyout_price} 灵石` });
  } catch (e) { await client.query('ROLLBACK'); res.status(500).json({ error: e.message }); }
  finally { client.release(); }
});

// GET /api/auction/my-listings - 我的上架列表
app.get('/api/auction/my-listings', auth, async (req, res) => {
  try {
    const listings = await pool.query(
      "SELECT * FROM auction_listings WHERE seller_wallet=$1 ORDER BY created_at DESC LIMIT 50",
      [req.user.wallet]
    );
    res.json({ listings: listings.rows });
  } catch (e) { res.status(500).json({ error: e.message }); }
});

// POST /api/auction/cancel - 取消上架
app.post('/api/auction/cancel', auth, async (req, res) => {
  try {
    const w = req.user.wallet;
    const { listing_id } = req.body;
    const listing = await pool.query("SELECT * FROM auction_listings WHERE id=$1 AND seller_wallet=$2 AND status='active'", [listing_id, w]);
    if (!listing.rows.length) return res.status(400).json({ error: '拍卖不存在' });
    const l = listing.rows[0];
    if (l.bid_count > 0) return res.status(400).json({ error: '已有人出价，无法取消' });

    // 物品退回
    await pool.query(
      `UPDATE players SET game_data = jsonb_set(game_data, '{items}', COALESCE(game_data->'items', '[]'::jsonb) || $1::jsonb) WHERE wallet = $2`,
      [JSON.stringify([l.item_data]), w]
    );
    await pool.query("UPDATE auction_listings SET status='cancelled' WHERE id=$1", [listing_id]);

    res.json({ ok: true, message: `${l.item_name} 已取消上架并退回背包` });
  } catch (e) { res.status(500).json({ error: e.message }); }
});

// GET /api/auction/my-bids - 我的出价记录
app.get('/api/auction/my-bids', auth, async (req, res) => {
  try {
    const bids = await pool.query(
      `SELECT ab.*, al.item_name, al.item_type, al.item_quality, al.item_data, al.status as listing_status, al.current_bid, al.current_bidder, al.expires_at, al.buyout_price
       FROM auction_bids ab JOIN auction_listings al ON ab.listing_id=al.id
       WHERE ab.bidder_wallet=$1 ORDER BY ab.created_at DESC LIMIT 50`,
      [req.user.wallet]
    );
    res.json({ bids: bids.rows });
  } catch (e) { res.status(500).json({ error: e.message }); }
});

// GET /api/auction/history - 最近成交记录
app.get('/api/auction/history', auth, async (req, res) => {
  try {
    const history = await pool.query(
      `SELECT ah.*, p1.name as seller_name, p2.name as buyer_name
       FROM auction_history ah
       LEFT JOIN players p1 ON ah.seller_wallet=p1.wallet
       LEFT JOIN players p2 ON ah.buyer_wallet=p2.wallet
       ORDER BY ah.sold_at DESC LIMIT 50`
    );
    res.json({ history: history.rows });
  } catch (e) { res.status(500).json({ error: e.message }); }
});

// ============ 拍卖行系统结束 ============


// ============ 每日副本系统 ============

// GET /api/dungeon-daily/list - 副本列表
app.get("/api/dungeon-daily/list", auth, async (req, res) => {
  try {
    const w = req.user.wallet;
    const player = await pool.query("SELECT level, combat_power, game_data FROM players WHERE wallet=$1", [w]);
    if (!player.rows.length) return res.status(404).json({ error: "玩家不存在" });
    const pLevel = player.rows[0].level || 1;

    const dungeons = await pool.query("SELECT * FROM daily_dungeons ORDER BY min_level ASC");
    const today = new Date().toISOString().slice(0, 10);
    const entries = await pool.query(
      "SELECT dungeon_id, COUNT(*)::int as used FROM daily_dungeon_entries WHERE wallet=$1 AND entry_date=$2 GROUP BY dungeon_id",
      [w, today]
    );
    const usedMap = {};
    entries.rows.forEach(r => { usedMap[r.dungeon_id] = r.used; });

    const list = dungeons.rows.map(d => ({
      id: d.id,
      name: d.name,
      description: d.description,
      difficulty: d.difficulty,
      min_level: d.min_level,
      max_entries: d.max_entries,
      enemy_config: d.enemy_config,
      rewards_config: d.rewards_config,
      used_entries: usedMap[d.id] || 0,
      remaining: d.max_entries - (usedMap[d.id] || 0),
      locked: pLevel < d.min_level
    }));

    res.json({ dungeons: list, playerLevel: pLevel });
  } catch (e) { res.status(500).json({ error: e.message }); }
});

// POST /api/dungeon-daily/enter - 进入副本
app.post("/api/dungeon-daily/enter", auth, async (req, res) => {
  try {
    const w = req.user.wallet;
    const { dungeon_id } = req.body;
    if (!dungeon_id) return res.status(400).json({ error: "缺少副本ID" });

    const player = await pool.query("SELECT * FROM players WHERE wallet=$1", [w]);
    if (!player.rows.length) return res.status(404).json({ error: "玩家不存在" });
    const p = player.rows[0];
    const pLevel = p.level || 1;
    const pCombat = Number(p.combat_power) || 100;
    const gameData = p.game_data || {};

    const dungeon = await pool.query("SELECT * FROM daily_dungeons WHERE id=$1", [dungeon_id]);
    if (!dungeon.rows.length) return res.status(404).json({ error: "副本不存在" });
    const d = dungeon.rows[0];

    if (pLevel < d.min_level) return res.status(400).json({ error: `等级不足，需要${d.min_level}级` });

    const today = new Date().toISOString().slice(0, 10);
    const used = await pool.query(
      "SELECT COUNT(*)::int as cnt FROM daily_dungeon_entries WHERE wallet=$1 AND dungeon_id=$2 AND entry_date=$3",
      [w, dungeon_id, today]
    );
    if (used.rows[0].cnt >= d.max_entries) return res.status(400).json({ error: "今日次数已用完" });

    // 战斗模拟
    const enemy = d.enemy_config;
    const enemyCombat = enemy.attack * 2 + enemy.defense + enemy.hp / 10;
    const winRate = pCombat / (pCombat + enemyCombat);
    const roll = Math.random();
    const victory = roll < winRate;

    // 生成战斗日志
    let playerHp = Math.max(1000, pCombat * 2);
    const playerMaxHp = playerHp;
    let enemyHp = enemy.hp;
    const enemyMaxHp = enemy.hp;
    const playerAtk = Math.max(50, pCombat * 0.3);
    const playerDef = Math.max(20, pCombat * 0.1);
    const combatLog = [];
    let round = 0;

    while (playerHp > 0 && enemyHp > 0 && round < 10) {
      round++;
      // 玩家攻击
      const pDmgBase = playerAtk * (0.8 + Math.random() * 0.4);
      const pDmgReduced = Math.max(1, pDmgBase - enemy.defense * 0.3);
      const pCrit = Math.random() < 0.15;
      const pFinalDmg = Math.floor(pCrit ? pDmgReduced * 1.5 : pDmgReduced);
      enemyHp = Math.max(0, enemyHp - pFinalDmg);
      combatLog.push({
        round, actor: "player", damage: pFinalDmg, crit: pCrit,
        enemyHp: Math.max(0, enemyHp), enemyMaxHp, playerHp, playerMaxHp
      });
      if (enemyHp <= 0) break;

      // 敌人攻击
      const eDmgBase = enemy.attack * (0.8 + Math.random() * 0.4);
      const eDmgReduced = Math.max(1, eDmgBase - playerDef * 0.3);
      const eCrit = Math.random() < 0.1;
      const eFinalDmg = Math.floor(eCrit ? eDmgReduced * 1.5 : eDmgReduced);
      playerHp = Math.max(0, playerHp - eFinalDmg);
      combatLog.push({
        round, actor: "enemy", damage: eFinalDmg, crit: eCrit,
        enemyHp, enemyMaxHp, playerHp: Math.max(0, playerHp), playerMaxHp
      });
    }

    // 根据预定胜负调整最后一条日志
    const result = victory ? "victory" : "defeat";
    if (victory && enemyHp > 0) {
      enemyHp = 0;
      combatLog.push({ round: round + 1, actor: "player", damage: enemyHp, crit: true, enemyHp: 0, enemyMaxHp, playerHp, playerMaxHp, finisher: true });
    } else if (!victory && playerHp > 0) {
      playerHp = 0;
      combatLog.push({ round: round + 1, actor: "enemy", damage: playerHp, crit: false, enemyHp, enemyMaxHp, playerHp: 0, playerMaxHp, finisher: true });
    }

    let rewards = {};
    if (victory) {
      const rc = d.rewards_config;
      rewards = { spiritStones: rc.spiritStones || 0, cultivation: rc.cultivation || 0 };
      if (rc.items) rewards.items = rc.items;
      if (rc.petEssence) rewards.petEssence = rc.petEssence;
      if (rc.refinementStones) rewards.refinementStones = rc.refinementStones;

      // 发放灵石、修为、焰兽精华、符文石
      const curStones = Number(gameData.spiritStones) || 0;
      const curCult = Number(gameData.cultivation) || 0;
      const curPE = Number(gameData.petEssence) || 0;
      const curRS = Number(gameData.refinementStones) || 0;
      let setExpr = `game_data = jsonb_set(jsonb_set(game_data, '{spiritStones}', to_jsonb(($1)::bigint)), '{cultivation}', to_jsonb(($2)::bigint))`;
      const params = [curStones + (rc.spiritStones || 0), curCult + (rc.cultivation || 0), rc.spiritStones || 0, w];
      let idx = 5;
      if (rc.petEssence) {
        setExpr = `game_data = jsonb_set(jsonb_set(jsonb_set(game_data, '{spiritStones}', to_jsonb(($1)::bigint)), '{cultivation}', to_jsonb(($2)::bigint)), '{petEssence}', to_jsonb(($${idx})::bigint))`;
        params.push(curPE + rc.petEssence);
        idx++;
      }
      if (rc.refinementStones) {
        if (rc.petEssence) {
          setExpr = `game_data = jsonb_set(jsonb_set(jsonb_set(jsonb_set(game_data, '{spiritStones}', to_jsonb(($1)::bigint)), '{cultivation}', to_jsonb(($2)::bigint)), '{petEssence}', to_jsonb(($${idx-1})::bigint)), '{refinementStones}', to_jsonb(($${idx})::bigint))`;
        } else {
          setExpr = `game_data = jsonb_set(jsonb_set(jsonb_set(game_data, '{spiritStones}', to_jsonb(($1)::bigint)), '{cultivation}', to_jsonb(($2)::bigint)), '{refinementStones}', to_jsonb(($${idx})::bigint))`;
        }
        params.push(curRS + rc.refinementStones);
        idx++;
      }
      await pool.query(
        `UPDATE players SET ${setExpr}, spirit_stones = spirit_stones + $3 WHERE wallet = $4`,
        params
      );
    }

    // 记录挑战
    await pool.query(
      "INSERT INTO daily_dungeon_entries (dungeon_id, wallet, player_name, result, rewards_earned, entry_date) VALUES ($1,$2,$3,$4,$5,$6)",
      [dungeon_id, w, p.name || "无名修士", result, JSON.stringify(rewards), today]
    );

    const remaining = d.max_entries - used.rows[0].cnt - 1;
    res.json({ result, combatLog, rewards, remaining, dungeonName: d.name, enemy: d.enemy_config });
  } catch (e) { res.status(500).json({ error: e.message }); }
});

// GET /api/dungeon-daily/history - 今日记录
app.get("/api/dungeon-daily/history", auth, async (req, res) => {
  try {
    const w = req.user.wallet;
    const today = new Date().toISOString().slice(0, 10);
    const rows = await pool.query(
      `SELECT dde.*, dd.name as dungeon_name, dd.difficulty
       FROM daily_dungeon_entries dde
       JOIN daily_dungeons dd ON dde.dungeon_id = dd.id
       WHERE dde.wallet=$1 AND dde.entry_date=$2
       ORDER BY dde.created_at DESC`,
      [w, today]
    );
    res.json({ history: rows.rows });
  } catch (e) { res.status(500).json({ error: e.message }); }
});

// ============ 每日副本系统结束 ============
// ============ 坐骑系统 ============

// GET /api/mount/list - 所有坐骑列表（含是否已拥有）
app.get('/api/mount/list', auth, async (req, res) => {
  try {
    const w = req.user.wallet;
    const mounts = await pool.query('SELECT * FROM mounts ORDER BY id');
    const owned = await pool.query('SELECT mount_id FROM player_mounts WHERE wallet = $1', [w]);
    const ownedIds = owned.rows.map(r => r.mount_id);
    const list = mounts.rows.map(m => ({ ...m, owned: ownedIds.includes(m.id) }));
    res.json({ mounts: list });
  } catch (e) { res.status(500).json({ error: e.message }); }
});

// GET /api/mount/my - 我的坐骑列表
app.get('/api/mount/my', auth, async (req, res) => {
  try {
    const w = req.user.wallet;
    const rows = await pool.query(
      `SELECT pm.*, m.name, m.description, m.quality, m.emoji, m.attack_bonus, m.defense_bonus,
              m.health_bonus, m.speed_bonus, m.special_effect, m.obtain_method
       FROM player_mounts pm JOIN mounts m ON pm.mount_id = m.id
       WHERE pm.wallet = $1 ORDER BY m.quality DESC, pm.id`, [w]);
    res.json({ mounts: rows.rows });
  } catch (e) { res.status(500).json({ error: e.message }); }
});

// POST /api/mount/buy - 购买坐骑
app.post('/api/mount/buy', auth, async (req, res) => {
  try {
    const w = req.user.wallet;
    const { mount_id } = req.body;
    if (!mount_id) return res.status(400).json({ error: '参数缺失' });

    const mount = await pool.query('SELECT * FROM mounts WHERE id = $1', [mount_id]);
    if (!mount.rows.length) return res.status(404).json({ error: '坐骑不存在' });
    const m = mount.rows[0];

    // 检查是否已拥有
    const exists = await pool.query('SELECT id FROM player_mounts WHERE wallet = $1 AND mount_id = $2', [w, mount_id]);
    if (exists.rows.length) return res.status(400).json({ error: '已拥有该坐骑' });

    // 白鹤免费，赤焰马10000灵石，其他不可购买
    let cost = 0;
    if (m.name === '白鹤') {
      cost = 0;
    } else if (m.name === '赤焰马') {
      cost = 10000;
    } else {
      return res.status(400).json({ error: '该坐骑无法购买，需通过特殊途径获得' });
    }

    if (cost > 0) {
      const player = await pool.query('SELECT spirit_stones FROM players WHERE wallet = $1', [w]);
      const stones = player.rows[0]?.spirit_stones || 0;
      if (stones < cost) return res.status(400).json({ error: `灵石不足，需要${cost}灵石` });
      await pool.query(
        `UPDATE players SET spirit_stones = spirit_stones - $1,
         game_data = jsonb_set(game_data, '{spiritStones}', to_jsonb(GREATEST(0, (COALESCE((game_data->>'spiritStones')::bigint, 0) - $1)::bigint)))
         WHERE wallet = $2`,
        [cost, w]
      );
    }

    await pool.query('INSERT INTO player_mounts (wallet, mount_id) VALUES ($1, $2)', [w, mount_id]);
    res.json({ success: true, message: `成功获得坐骑: ${m.name}`, cost });
  } catch (e) { res.status(500).json({ error: e.message }); }
});

// POST /api/mount/activate - 激活坐骑
app.post('/api/mount/activate', auth, async (req, res) => {
  try {
    const w = req.user.wallet;
    const { player_mount_id } = req.body;
    if (!player_mount_id) return res.status(400).json({ error: '参数缺失' });

    const pm = await pool.query('SELECT * FROM player_mounts WHERE id = $1 AND wallet = $2', [player_mount_id, w]);
    if (!pm.rows.length) return res.status(404).json({ error: '坐骑不存在' });

    // 先取消所有激活
    await pool.query('UPDATE player_mounts SET is_active = false WHERE wallet = $1', [w]);
    // 激活选中的
    await pool.query('UPDATE player_mounts SET is_active = true WHERE id = $1', [player_mount_id]);
    res.json({ success: true });
  } catch (e) { res.status(500).json({ error: e.message }); }
});

// POST /api/mount/deactivate - 取消激活
app.post('/api/mount/deactivate', auth, async (req, res) => {
  try {
    const w = req.user.wallet;
    await pool.query('UPDATE player_mounts SET is_active = false WHERE wallet = $1', [w]);
    res.json({ success: true });
  } catch (e) { res.status(500).json({ error: e.message }); }
});

// GET /api/mount/active - 当前激活的坐骑
app.get('/api/mount/active', auth, async (req, res) => {
  try {
    const w = req.user.wallet;
    const row = await pool.query(
      `SELECT pm.*, m.name, m.description, m.quality, m.emoji, m.attack_bonus, m.defense_bonus,
              m.health_bonus, m.speed_bonus, m.special_effect
       FROM player_mounts pm JOIN mounts m ON pm.mount_id = m.id
       WHERE pm.wallet = $1 AND pm.is_active = true`, [w]);
    res.json({ mount: row.rows[0] || null });
  } catch (e) { res.status(500).json({ error: e.message }); }
});

// ============ 坐骑系统结束 ============

// ============ 称号系统 ============

// GET /api/title/list - 所有称号列表（含解锁状态+进度）
app.get('/api/title/list', auth, async (req, res) => {
  try {
    const w = req.user.wallet;
    const titles = await pool.query('SELECT * FROM titles ORDER BY id');
    const unlocked = await pool.query('SELECT title_id FROM player_titles WHERE wallet = $1', [w]);
    const unlockedIds = unlocked.rows.map(r => r.title_id);

    // 获取玩家数据用于进度计算
    const player = await pool.query('SELECT level, spirit_stones, game_data FROM players WHERE wallet = $1', [w]);
    const p = player.rows[0] || {};
    const gd = p.game_data || {};

    const list = titles.rows.map(t => {
      let progress = 0;
      let current = 0;
      switch (t.condition_type) {
        case 'level': current = p.level || 1; break;
        case 'kills': current = (gd.dungeonTotalKills || 0) + (gd.explorationCount || 0); break;
        case 'dungeon_floor': current = gd.dungeonHighestFloor || 0; break;
        case 'spirit_stones': current = p.spirit_stones || 0; break;
        case 'friends': current = gd.friendCount || 0; break;
        case 'contribution': current = gd.sectContribution || 0; break;
        case 'boss_kill': current = gd.dungeonBossKills || 0; break;
      }
      progress = Math.min(100, Math.floor((current / t.condition_value) * 100));
      return { ...t, unlocked: unlockedIds.includes(t.id), progress, current };
    });
    res.json({ titles: list });
  } catch (e) { res.status(500).json({ error: e.message }); }
});

// GET /api/title/my - 我已解锁的称号
app.get('/api/title/my', auth, async (req, res) => {
  try {
    const w = req.user.wallet;
    const rows = await pool.query(
      `SELECT pt.*, t.name, t.description, t.quality, t.color, t.condition_type, t.condition_value,
              t.attack_bonus, t.defense_bonus, t.health_bonus
       FROM player_titles pt JOIN titles t ON pt.title_id = t.id
       WHERE pt.wallet = $1 ORDER BY t.quality DESC, pt.id`, [w]);
    res.json({ titles: rows.rows });
  } catch (e) { res.status(500).json({ error: e.message }); }
});

// POST /api/title/check - 检查并解锁新称号
app.post('/api/title/check', auth, async (req, res) => {
  try {
    const w = req.user.wallet;
    const player = await pool.query('SELECT level, spirit_stones, game_data FROM players WHERE wallet = $1', [w]);
    const p = player.rows[0] || {};
    const gd = p.game_data || {};

    // 获取好友数
    let friendCount = 0;
    try {
      const fc = await pool.query('SELECT COUNT(*) as cnt FROM friendships WHERE (from_wallet = $1 OR to_wallet = $1) AND status = \'accepted\'', [w]);
      friendCount = parseInt(fc.rows[0]?.cnt || 0);
    } catch(e) { friendCount = gd.friendCount || 0; }

    // 获取宗门贡献
    let contribution = 0;
    try {
      const sc = await pool.query('SELECT contribution FROM sect_members WHERE wallet = $1', [w]);
      contribution = sc.rows[0]?.contribution || 0;
    } catch(e) { contribution = gd.sectContribution || 0; }

    const allTitles = await pool.query('SELECT * FROM titles ORDER BY id');
    const owned = await pool.query('SELECT title_id FROM player_titles WHERE wallet = $1', [w]);
    const ownedIds = owned.rows.map(r => r.title_id);

    const newlyUnlocked = [];
    for (const t of allTitles.rows) {
      if (ownedIds.includes(t.id)) continue;
      let current = 0;
      switch (t.condition_type) {
        case 'level': current = p.level || 1; break;
        case 'kills': current = (gd.dungeonTotalKills || 0) + (gd.explorationCount || 0); break;
        case 'dungeon_floor': current = gd.dungeonHighestFloor || 0; break;
        case 'spirit_stones': current = p.spirit_stones || 0; break;
        case 'friends': current = friendCount; break;
        case 'contribution': current = contribution; break;
        case 'boss_kill': current = gd.dungeonBossKills || 0; break;
      }
      if (current >= t.condition_value) {
        await pool.query('INSERT INTO player_titles (wallet, title_id) VALUES ($1, $2)', [w, t.id]);
        newlyUnlocked.push(t);
      }
    }
    res.json({ newlyUnlocked, count: newlyUnlocked.length });
  } catch (e) { res.status(500).json({ error: e.message }); }
});

// POST /api/title/activate - 佩戴称号
app.post('/api/title/activate', auth, async (req, res) => {
  try {
    const w = req.user.wallet;
    const { player_title_id } = req.body;
    if (!player_title_id) return res.status(400).json({ error: '参数缺失' });

    const pt = await pool.query('SELECT * FROM player_titles WHERE id = $1 AND wallet = $2', [player_title_id, w]);
    if (!pt.rows.length) return res.status(404).json({ error: '称号不存在' });

    await pool.query('UPDATE player_titles SET is_active = false WHERE wallet = $1', [w]);
    await pool.query('UPDATE player_titles SET is_active = true WHERE id = $1', [player_title_id]);
    res.json({ success: true });
  } catch (e) { res.status(500).json({ error: e.message }); }
});

// POST /api/title/deactivate - 取消佩戴
app.post('/api/title/deactivate', auth, async (req, res) => {
  try {
    const w = req.user.wallet;
    await pool.query('UPDATE player_titles SET is_active = false WHERE wallet = $1', [w]);
    res.json({ success: true });
  } catch (e) { res.status(500).json({ error: e.message }); }
});

// ============ 称号系统结束 ============

// ============ 飞升系统 ============

// GET /api/ascension/info - 飞升信息
app.get('/api/ascension/info', auth, async (req, res) => {
  try {
    const w = req.user.wallet;
    const player = await pool.query('SELECT * FROM players WHERE wallet = $1', [w]);
    if (!player.rows.length) return res.status(404).json({ error: '玩家不存在' });

    const p = player.rows[0];
    const gd = p.game_data || {};
    const ascensionCount = gd.ascensionCount || 0;
    const ascensionBonuses = gd.ascensionBonuses || { attack: 0, defense: 0, health: 0, speed: 0, cultivationSpeed: 0 };

    // 获取飞升历史
    const history = await pool.query(
      'SELECT * FROM ascension_records WHERE wallet = $1 ORDER BY ascended_at DESC',
      [w]
    );

    // 获取下次飞升加成
    let nextPerk = null;
    if (ascensionCount < 7) {
      const np = await pool.query('SELECT * FROM ascension_perks WHERE ascension_level = $1', [ascensionCount + 1]);
      if (np.rows.length) nextPerk = np.rows[0];
    }

    res.json({
      ascensionCount,
      maxAscension: 7,
      currentLevel: p.level || gd.level || 1,
      requiredLevel: 100,
      canAscend: (p.level || gd.level || 1) >= 100 && ascensionCount < 7,
      currentBonuses: ascensionBonuses,
      nextPerk,
      history: history.rows
    });
  } catch (e) { res.status(500).json({ error: e.message }); }
});

// POST /api/ascension/ascend - 执行飞升
app.post('/api/ascension/ascend', auth, async (req, res) => {
  try {
    const w = req.user.wallet;
    const player = await pool.query('SELECT * FROM players WHERE wallet = $1', [w]);
    if (!player.rows.length) return res.status(404).json({ error: '玩家不存在' });

    const p = player.rows[0];
    const gd = p.game_data || {};
    const currentLevel = p.level || gd.level || 1;
    const ascensionCount = gd.ascensionCount || 0;

    // 检查条件
    if (currentLevel < 100) return res.status(400).json({ error: '等级不足，需要达到100级' });
    if (ascensionCount >= 7) return res.status(400).json({ error: '已达到最大飞升次数' });

    const newAscensionCount = ascensionCount + 1;

    // 获取本次飞升加成
    const perkResult = await pool.query('SELECT * FROM ascension_perks WHERE ascension_level = $1', [newAscensionCount]);
    if (!perkResult.rows.length) return res.status(500).json({ error: '飞升加成数据缺失' });
    const perk = perkResult.rows[0];

    // 本次飞升的加成就是该等级的加成值（非累加，每次飞升覆盖为该等级的值）
    const newBonuses = {
      attack: perk.attack_bonus,
      defense: perk.defense_bonus,
      health: perk.health_bonus,
      speed: perk.speed_bonus,
      cultivationSpeed: perk.cultivation_speed_bonus
    };

    // 保留10%灵石
    const currentStones = p.spirit_stones || gd.spiritStones || 0;
    const retainedStones = Math.floor(currentStones * 0.1);
    const rewardStones = 10000 * newAscensionCount;

    // 构建重置后的 game_data，保留飞升相关字段
    const newGameData = {
      ...gd,
      level: 1,
      cultivation: 0,
      spiritStones: retainedStones + rewardStones,
      baseAttributes: { attack: 10, defense: 5, health: 100, speed: 10 },
      combatAttributes: { critRate: 0, comboRate: 0, counterRate: 0, stunRate: 0, dodgeRate: 0, vampireRate: 0 },
      items: [],
      equippedArtifacts: {},
      ascensionCount: newAscensionCount,
      ascensionBonuses: newBonuses
    };

    // 记录飞升
    await pool.query(
      'INSERT INTO ascension_records (wallet, ascension_count, previous_level, bonuses) VALUES ($1, $2, $3, $4)',
      [w, newAscensionCount, currentLevel, JSON.stringify(newBonuses)]
    );

    // 更新玩家数据
    await pool.query(
      'UPDATE players SET game_data = $1, level = 1, spirit_stones = $2 WHERE wallet = $3',
      [JSON.stringify(newGameData), retainedStones + rewardStones, w]
    );

    // 飞升称号
    const titleName = '第' + newAscensionCount + '世飞升者';

    res.json({
      success: true,
      ascensionCount: newAscensionCount,
      perk: {
        name: perk.name,
        description: perk.description,
        bonuses: newBonuses,
        specialPerk: perk.special_perk
      },
      rewards: {
        spiritStones: rewardStones,
        retainedStones,
        title: titleName
      },
      reset: {
        level: 1,
        cultivation: 0,
        spiritStones: retainedStones + rewardStones
      }
    });
  } catch (e) { res.status(500).json({ error: e.message }); }
});

// GET /api/ascension/perks - 所有飞升加成列表
app.get('/api/ascension/perks', auth, async (req, res) => {
  try {
    const w = req.user.wallet;
    const player = await pool.query('SELECT game_data FROM players WHERE wallet = $1', [w]);
    const gd = player.rows[0]?.game_data || {};
    const ascensionCount = gd.ascensionCount || 0;

    const perks = await pool.query('SELECT * FROM ascension_perks ORDER BY ascension_level');
    const result = perks.rows.map(p => ({
      ...p,
      unlocked: p.ascension_level <= ascensionCount
    }));

    res.json({ perks: result, currentAscension: ascensionCount });
  } catch (e) { res.status(500).json({ error: e.message }); }
});

// GET /api/ascension/ranking - 飞升排行榜
app.get('/api/ascension/ranking', auth, async (req, res) => {
  try {
    const result = await pool.query(
      "SELECT p.wallet, p.name, p.level, COALESCE((p.game_data->>'ascensionCount')::int, 0) as ascension_count FROM players p WHERE COALESCE((p.game_data->>'ascensionCount')::int, 0) > 0 ORDER BY ascension_count DESC, p.level DESC LIMIT 50"
    );

    res.json({ ranking: result.rows.map((r, i) => ({ rank: i + 1, ...r })) });
  } catch (e) { res.status(500).json({ error: e.message }); }
});

// ============ 飞升系统结束 ============

// ============ 背包扩容系统 ============
const EXPAND_CONFIG = {
  equip:   { base: 100, perLevel: 20, maxLevel: 10, basePrice: 5000 },
  herb:    { base: 200, perLevel: 50, maxLevel: 8,  basePrice: 3000 },
  pill:    { base: 50,  perLevel: 10, maxLevel: 10, basePrice: 4000 },
  pet:     { base: 30,  perLevel: 5,  maxLevel: 10, basePrice: 8000 },
  formula: { base: 50,  perLevel: 10, maxLevel: 5,  basePrice: 6000 },
};

app.get('/api/storage/info', auth, async (req, res) => {
  try {
    const player = await pool.query('SELECT game_data FROM players WHERE wallet=$1', [req.user.wallet]);
    if (!player.rows.length) return res.status(404).json({ error: '玩家不存在' });
    const gd = typeof player.rows[0].game_data === 'string' ? JSON.parse(player.rows[0].game_data) : (player.rows[0].game_data || {});
    const expand = gd.storageExpand || {};
    const info = {};
    for (const [cat, cfg] of Object.entries(EXPAND_CONFIG)) {
      const level = expand[cat] || 0;
      info[cat] = { level, limit: cfg.base + cfg.perLevel * level, maxLevel: cfg.maxLevel, nextCost: level < cfg.maxLevel ? cfg.basePrice * (level + 1) : null };
    }
    res.json({ success: true, info });
  } catch (e) { res.status(500).json({ error: e.message }); }
});

app.post('/api/storage/expand', auth, async (req, res) => {
  try {
    const { category } = req.body;
    if (!EXPAND_CONFIG[category]) return res.status(400).json({ error: '无效分类' });
    const cfg = EXPAND_CONFIG[category];
    const player = await pool.query('SELECT spirit_stones, game_data FROM players WHERE wallet=$1', [req.user.wallet]);
    if (!player.rows.length) return res.status(404).json({ error: '玩家不存在' });
    const gd = typeof player.rows[0].game_data === 'string' ? JSON.parse(player.rows[0].game_data) : (player.rows[0].game_data || {});
    if (!gd.storageExpand) gd.storageExpand = {};
    const currentLevel = gd.storageExpand[category] || 0;
    if (currentLevel >= cfg.maxLevel) return res.json({ success: false, error: '已达最大扩容等级' });
    const cost = cfg.basePrice * (currentLevel + 1);
    const stones = Math.max(gd.spiritStones || 0, player.rows[0].spirit_stones || 0);
    if (stones < cost) return res.json({ success: false, error: `焰晶不足，需要${cost}焰晶` });
    const remaining = stones - cost;
    gd.spiritStones = remaining;
    gd.storageExpand[category] = currentLevel + 1;
    const newLimit = cfg.base + cfg.perLevel * (currentLevel + 1);
    await pool.query('UPDATE players SET game_data=$1, spirit_stones=$2 WHERE wallet=$3', [JSON.stringify(gd), remaining, req.user.wallet]);
    res.json({ success: true, newLimit, cost, remaining, level: currentLevel + 1 });
  } catch (e) { res.status(500).json({ error: e.message }); }
});
// ============ 背包扩容系统结束 ============

// ============ Admin 后台路由 ============
import registerAdminRoutes from './admin-routes.js';
import { registerDungeonRoutes } from './routes/dungeon.js';
await registerAdminRoutes(app, pool, auth, adminAuth);

// === 焚天塔副本系统 ===
registerDungeonRoutes(app, pool, auth);
server.listen(PORT, () => console.log(`修仙后端启动 port ${PORT}`));
