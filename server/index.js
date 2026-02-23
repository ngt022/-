import dotenv from 'dotenv';
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';
const __dirname_env = dirname(fileURLToPath(import.meta.url));
const _gameEnv = process.env.GAME_ENV || 'production';
dotenv.config({ path: join(__dirname_env, '.env.' + _gameEnv) });
dotenv.config({ path: join(__dirname_env, '.env') });
logger.info('[ENV] GAME_ENV=' + _gameEnv + ' DB=' + (process.env.DATABASE_URL || '').split('/').pop());
import express from 'express';
import cors from 'cors';
import pg from 'pg';
import jwt from 'jsonwebtoken';
import { ethers } from 'ethers';
import rateLimit from 'express-rate-limit';
import helmet from 'helmet';
import { createServer } from 'http';
import { WebSocketServer } from 'ws';
import { recalcAndPatch, computeFinalStats, getPlayerFinalStats, getMountTitleBonuses, logBattleTrace } from './services/stats-service.js';
import { idempotent } from './services/lock-service.js';
import logger, { requestLogger } from './services/logger.js';

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
const RATE_PER_ROON = 10000; // 1 ROON = 10000 焰晶
const FIRST_RECHARGE_BONUS = 2; // 首充双倍

const pool = new pg.Pool({
  connectionString: process.env.DATABASE_URL || 'postgresql://roon_user:changeme@localhost:5432/xiuxian',
  max: 20,
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 5000,
});


// DB 连接池错误处理
pool.on('error', (err) => {
  logger.error('[DB] Pool error:', err.message);
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
  { day: 1, stones: 500, reinforceStones: 2, refinementStones: 0, items: '淬火石x2' },
  { day: 2, stones: 800, reinforceStones: 0, refinementStones: 2, items: '符文石x2' },
  { day: 3, stones: 1200, reinforceStones: 5, refinementStones: 0, items: '淬火石x5' },
  { day: 4, stones: 1500, reinforceStones: 0, refinementStones: 5, items: '符文石x5' },
  { day: 5, stones: 2000, reinforceStones: 10, refinementStones: 5, items: '淬火石x10+符文石x5' },
  { day: 6, stones: 3000, reinforceStones: 5, refinementStones: 10, items: '淬火石x5+符文石x10' },
  { day: 7, stones: 8000, reinforceStones: 20, refinementStones: 15, petEssence: 50, items: '淬火石x20+符文石x15+精华x50' },
];

// 请求日志（只记录异常和慢请求）
app.use((req, res, next) => {
  const start = Date.now();
  const origEnd = res.end;
  res.end = function(...args) {
    const ms = Date.now() - start;
    if (res.statusCode >= 400 || ms > 2000) {
      logger.info(`[${new Date().toISOString()}] ${req.method} ${req.originalUrl} ${res.statusCode} ${ms}ms`);
    }
    origEnd.apply(this, args);
  };
  next();
});

// 请求响应时间 header（在响应发送前设置）
app.use((req, res, next) => {
  const start = Date.now();
  const origEnd = res.end;
  res.end = function(...args) {
    if (!res.headersSent) {
      res.set('X-Response-Time', (Date.now() - start) + 'ms');
    }
    origEnd.apply(this, args);
  };
  next();
});

app.use(helmet({ contentSecurityPolicy: false }));
app.use(cors({
  origin: (origin, cb) => {
    // 允许无 origin（同源/curl/移动端）+ localhost + 自身IP
    if (!origin || origin.includes('localhost') || origin.includes('23.95.222.209') || origin.includes('127.0.0.1')) {
      cb(null, true);
    } else {
      cb(null, true); // 暂时放行，有域名后收紧
    }
  },
  credentials: true
}));
app.use(express.json({ limit: '1mb' }));
app.use(rateLimit({ windowMs: 60000, max: 120 }));

// 敏感操作更严格的限流

// Health check (不需要认证)
app.get('/api/health', async (req, res) => {
  try {
    await pool.query('SELECT 1');
    res.json({ status: 'ok', uptime: process.uptime(), memory: Math.round(process.memoryUsage().rss / 1024 / 1024) + 'MB', ws: wss.clients.size });
  } catch (e) {
    res.status(503).json({ status: 'error', error: safeError(e) });
  }
});

// 生产环境不泄露内部错误细节
function safeError(e) {
  if (process.env.NODE_ENV === 'production') return '服务器内部错误';
  return e.message;
}

// === 从 equippedArtifacts 重算所有派生属性 (M1: delegated to stats-service) ===
function recalcDerivedStats(gd) {
  return recalcAndPatch(gd);
}


const strictLimit = rateLimit({ windowMs: 60000, max: 10, message: { error: '操作太频繁，请稍后再试' } });
const authLimit = rateLimit({ windowMs: 300000, max: 5, message: { error: '登录尝试太频繁' } });

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
app.post('/api/auth/login', authLimit, async (req, res) => {
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
      // 新玩家欢迎邮件
      await pool.query(
        `INSERT INTO player_mail (to_wallet, from_type, from_name, title, content, rewards) VALUES ($1, 'system', '系统', '🔥 欢迎来到火之文明！', '欢迎加入焰修世界！这是你的新手礼物，祝你修炼顺利！提示：1.先去修炼积累焰力 2.去探索获取资源 3.去焰运阁抽装备 4.记得每日签到！', $2)`,
        [wallet.toLowerCase(), JSON.stringify({spiritStones: 10000, reinforceStones: 20})]
      );
    }

    const player = result.rows[0];
    const token = jwt.sign({ wallet: player.wallet, id: player.id }, JWT_SECRET, { expiresIn: '7d' });

    // 记录登录日志
    const ip = req.headers['x-forwarded-for'] || req.ip || 'unknown';
    pool.query('INSERT INTO login_logs (wallet, ip, user_agent) VALUES ($1, $2, $3)',
      [player.wallet, ip, (req.headers['user-agent'] || '').slice(0, 200)]).catch(() => {});
    res.json({ token, player: sanitizePlayer(player) });
  } catch (e) {
    res.status(500).json({ error: safeError(e) });
  }
});

// === 保存游戏数据 ===
app.post('/api/game/save', auth, async (req, res) => {
  try {
    const { gameData, combatPower, level, realm, name } = req.body;

    // Read DB current data - protect server-managed fields from frontend overwrite
    const current = await pool.query('SELECT game_data, level, realm, name, spirit_stones FROM players WHERE wallet = $1', [req.user.wallet]);
    if (!current.rows.length) return res.status(404).json({ error: '玩家不存在' });
    
    const oldLevel = current.rows[0]?.level || 1;
    const playerName = name || current.rows[0]?.name || '无名焰修';
    const dbGameData = typeof current.rows[0].game_data === 'string' 
      ? JSON.parse(current.rows[0].game_data) 
      : (current.rows[0].game_data || {});
    
    // Server-managed fields: use DB values, never accept frontend overwrite
    const serverManagedFields = [
      'dungeonHighestFloor', 'dungeonHighestFloor_2', 'dungeonHighestFloor_5', 'dungeonHighestFloor_10', 'dungeonHighestFloor_100',
      'dungeonTotalKills', 'dungeonBossKills', 'dungeonEliteKills', 'dungeonTotalRewards', 'dungeonTotalRuns', 'dungeonDeathCount', 'dungeonLastFailedFloor','spiritStones', 'items', 'reinforceStones', 'refinementStones', 'petEssence', 
      'purchasedPacks', 'buffs', 'herbs', 'pillRecipes', 'pillFragments',
      'storageExpand', 'autoSellQualities', 'autoReleaseRarities', 'shopWeeklyPurchases', 'activePet', 'pets', 'equippedArtifacts', 'baseAttributes', 'vipLevel', 'activeMount', 'activeTitle', 'realmName', 'realmIndex', 'combatAttributes', 'specialAttributes', 'combatResistance', 'artifactBonuses', 'activeMountBonus', 'activeTitleBonus', 'completedAchievements', 'nameChangeCount', 'pillsConsumed', 'pillsCrafted', 'explorationCount', 'itemsFound', 'breakthroughCount', 'selectedWishEquipQuality', 'selectedWishPetRarity', 'isNewPlayer', 'name', '_nakedBase'];
    
    // Merge: frontend data as base, but server-managed fields use DB values
    const mergedData = { ...gameData };
    for (const field of serverManagedFields) {
      if (dbGameData[field] !== undefined) {
        mergedData[field] = dbGameData[field];
      }
    }
    
    // 离线收益上限校验：防止前端篡改 cultivation/spirit
    const dbCult = Number(dbGameData.cultivation) || 0;
    const dbSpirit = Number(dbGameData.spirit) || 0;
    const newCult = Number(mergedData.cultivation) || 0;
    const newSpirit = Number(mergedData.spirit) || 0;
    const playerLevel = level || 1;
    // 最大离线12小时(720分钟)，VIP5最高2.5倍
    const maxCultPerMin = Math.floor(Math.pow(1.2, playerLevel - 1) * 0.5) * 2.5;
    const maxSpiritPerMin = Math.floor(playerLevel * 3 + 10) * 2.5;
    const maxOfflineMin = 720;
    const maxCultGain = maxCultPerMin * maxOfflineMin + 10000; // 加缓冲
    const maxSpiritGain = maxSpiritPerMin * maxOfflineMin + 5000;
    if (newCult - dbCult > maxCultGain) {
      mergedData.cultivation = dbCult + maxCultGain;
      logger.info('[AntiCheat] cultivation capped for', req.user.wallet, 'tried:', newCult - dbCult, 'max:', maxCultGain);
    }
    if (newSpirit - dbSpirit > maxSpiritGain) {
      mergedData.spirit = dbSpirit + maxSpiritGain;
      logger.info('[AntiCheat] spirit capped for', req.user.wallet, 'tried:', newSpirit - dbSpirit, 'max:', maxSpiritGain);
    }

    // spirit_stones column also uses DB value
    const dbSpiritStones = current.rows[0].spirit_stones ?? mergedData.spiritStones ?? 0;

    // Sync column-level fields into game_data so they survive serverManagedFields merge
    mergedData.vipLevel = current.rows[0].vip_level || 0;

    logger.info('[SAVE]', req.user.wallet.slice(-6), 'cult:', dbCult, '->', mergedData.cultivation, 'lv:', level);
    await pool.query(
      `UPDATE players SET game_data = $1, combat_power = $2, level = $3, realm = $4, 
       spirit_stones = $5, name = $6, state_version = state_version + 1, updated_at = NOW() WHERE wallet = $7`,
      [JSON.stringify(mergedData), combatPower || 0, mergedData.level || level || oldLevel, mergedData.realm || realm || current.rows[0]?.realm || '燃火期一层',
       dbSpiritStones, playerName, req.user.wallet]
    );

    // Breakthrough broadcast
    if (level > oldLevel && app.locals.broadcastEvent) {
      app.locals.broadcastEvent(`⚡ ${playerName} 突破至 ${realm}！`, 'breakthrough');
    }

    // Return DB real values so frontend can sync
    res.json({ ok: true, spiritStones: dbSpiritStones, items: mergedData.items });
  } catch (e) {
    res.status(500).json({ error: safeError(e) });
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
    const current = await pool.query('SELECT game_data, level, realm, name, spirit_stones FROM players WHERE wallet = $1', [user.wallet]);
    if (!current.rows.length) return res.status(404).json({ error: '玩家不存在' });
    
    const oldLevel = current.rows[0]?.level || 1;
    const playerName = name || current.rows[0]?.name || '无名焰修';
    const dbGameData = typeof current.rows[0].game_data === 'string'
      ? JSON.parse(current.rows[0].game_data)
      : (current.rows[0].game_data || {});

    const serverManagedFields = [
      'dungeonHighestFloor', 'dungeonHighestFloor_2', 'dungeonHighestFloor_5', 'dungeonHighestFloor_10', 'dungeonHighestFloor_100',
      'dungeonTotalKills', 'dungeonBossKills', 'dungeonEliteKills', 'dungeonTotalRewards', 'dungeonTotalRuns', 'dungeonDeathCount', 'dungeonLastFailedFloor','spiritStones', 'items', 'reinforceStones', 'refinementStones', 'petEssence',
      'purchasedPacks', 'buffs', 'herbs', 'pillRecipes', 'pillFragments',
      'storageExpand', 'autoSellQualities', 'autoReleaseRarities', 'shopWeeklyPurchases', 'activePet', 'pets', 'equippedArtifacts', 'baseAttributes', 'vipLevel', 'activeMount', 'activeTitle', 'realmName', 'realmIndex', 'combatAttributes', 'specialAttributes', 'combatResistance', 'artifactBonuses', 'activeMountBonus', 'activeTitleBonus', 'completedAchievements', 'nameChangeCount', 'pillsConsumed', 'pillsCrafted', 'explorationCount', 'itemsFound', 'breakthroughCount', 'selectedWishEquipQuality', 'selectedWishPetRarity', 'isNewPlayer', 'name', '_nakedBase'];

    const mergedData = { ...gameData };
    for (const field of serverManagedFields) {
      if (dbGameData[field] !== undefined) {
        mergedData[field] = dbGameData[field];
      }
    }
    // 离线收益上限校验
    const dbCultB = Number(dbGameData.cultivation) || 0;
    const dbSpiritB = Number(dbGameData.spirit) || 0;
    const newCultB = Number(mergedData.cultivation) || 0;
    const newSpiritB = Number(mergedData.spirit) || 0;
    const plvB = level || 1;
    const maxCultGainB = Math.floor(Math.pow(1.2, plvB - 1) * 0.5) * 2.5 * 720 + 10000;
    const maxSpiritGainB = Math.floor(plvB * 3 + 10) * 2.5 * 720 + 5000;
    if (newCultB - dbCultB > maxCultGainB) mergedData.cultivation = dbCultB + maxCultGainB;
    if (newSpiritB - dbSpiritB > maxSpiritGainB) mergedData.spirit = dbSpiritB + maxSpiritGainB;

    const dbSpiritStones = current.rows[0].spirit_stones ?? mergedData.spiritStones ?? 0;

    // Sync column-level fields into game_data
    mergedData.vipLevel = current.rows[0].vip_level || 0;

    await pool.query(
      `UPDATE players SET game_data = $1, combat_power = $2, level = $3, realm = $4,
       spirit_stones = $5, name = $6, state_version = state_version + 1, updated_at = NOW() WHERE wallet = $7`,
      [JSON.stringify(mergedData), combatPower || 0, mergedData.level || level || oldLevel, mergedData.realm || realm || current.rows[0]?.realm || '燃火期一层',
       dbSpiritStones, playerName, user.wallet]
    );

    if (level > oldLevel && app.locals.broadcastEvent) {
      app.locals.broadcastEvent(`⚡ ${playerName} 突破至 ${realm}！`, 'breakthrough');
    }
    res.json({ ok: true });
  } catch (e) {
    res.status(500).json({ error: safeError(e) });
  }
});

// === 加载游戏数据 ===
app.get('/api/game/load', auth, async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM players WHERE wallet = $1', [req.user.wallet]);
    if (result.rows.length === 0) return res.status(404).json({ error: '玩家不存在' });
    res.json({ player: sanitizePlayer(result.rows[0]) });
  } catch (e) {
    res.status(500).json({ error: safeError(e) });
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
import gameConfigApiRoutes from './routes/game-config-api.js';
app.use("/api/admin", gameBalanceRoutes);
app.use('/api/exploration', explorationRoutes(pool, auth));
app.use('/api/game', gameConfigApiRoutes);
app.use('/api/gacha', gachaRoutes);
app.use('/api/equipment', equipmentRoutes);
// app.use('/api/pets', petsRoutes); // disabled: pets managed via game_data.items

// === 探索奖励同步 ===
app.post('/api/exploration/reward', auth, async (req, res) => {
  try {
    const w = req.user.wallet;
    const { type, amount } = req.body;
    if (!type || !amount || amount <= 0) return res.status(400).json({ error: '参数无效' });

    // 防作弊：探索奖励上限（基于等级）
    const player = await pool.query('SELECT level FROM players WHERE wallet=$1', [w]);
    const plv = player.rows[0]?.level || 1;
    const maxStoneReward = Math.floor(plv * 50 + 200); // 最大焰晶奖励
    if (type === 'spirit_stone' && amount > maxStoneReward) {
      logger.info('[AntiCheat] exploration reward capped for', w, 'tried:', amount, 'max:', maxStoneReward);
      return res.status(400).json({ error: '奖励异常' });
    }

    if (type === 'spirit_stone') {
      // 检查双倍卡
      const erGd = await pool.query('SELECT game_data FROM players WHERE wallet=$1', [w]);
      const erData = erGd.rows[0]?.game_data || {};
      const finalAmount = isBuffActive(erData, 'doubleCrystal') ? amount * 2 : amount;
      await pool.query(
        `UPDATE players SET spirit_stones = spirit_stones + $1,
         game_data = jsonb_set(game_data, '{spiritStones}', to_jsonb((COALESCE((game_data->>'spiritStones')::bigint, 0) + $1)::bigint))
         WHERE wallet = $2`,
        [finalAmount, w]
      );
      res.json({ ok: true, type, amount: finalAmount });
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
  } catch (e) { res.status(500).json({ error: safeError(e) }); }
});

// === 充值确认 ===
app.post('/api/recharge/confirm', strictLimit, auth, async (req, res) => {
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
    const pName = (await pool.query('SELECT name FROM players WHERE wallet=$1', [req.user.wallet])).rows[0]?.name || '无名焰修';
    if (newVipLevel > player.rows[0].vip_level) {
      app.locals.broadcastEvent(`🎉 ${pName} 晋升为 VIP${newVipLevel}！`, 'vip');
    }
    if (!player.rows[0].first_recharge) {
      app.locals.broadcastEvent(`✨ ${pName} 完成了首充，获得双倍焰晶！`, 'recharge');
    }
  } catch (e) {
    res.status(500).json({ error: safeError(e) });
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
    res.status(500).json({ error: safeError(e) });
  }
});

function isBuffActive(gameData, key) {
  return gameData?.buffs?.[key] && gameData.buffs[key] > Date.now();
}

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

    // 检查双倍卡buff
    const gdResult = await pool.query('SELECT game_data FROM players WHERE wallet = $1', [req.user.wallet]);
    const signGd = typeof gdResult.rows[0].game_data === 'string' ? JSON.parse(gdResult.rows[0].game_data) : (gdResult.rows[0].game_data || {});
    const signStones = isBuffActive(signGd, 'doubleCrystal') ? reward.stones * 2 : reward.stones;

    // 发放焰晶
    await pool.query(
      `UPDATE players SET daily_sign_date = $1, daily_sign_streak = $2, 
       spirit_stones = spirit_stones + $3,
       game_data = jsonb_set(game_data, '{spiritStones}', to_jsonb((COALESCE((game_data->>'spiritStones')::bigint, 0) + $3)::bigint)),
       updated_at = NOW() WHERE wallet = $4`,
      [today, streak, signStones, req.user.wallet]
    );
    // 发放材料奖励
    if (reward.reinforceStones || reward.refinementStones || reward.petEssence) {
      const updates = [];
      const vals = [req.user.wallet];
      let idx = 2;
      if (reward.reinforceStones) {
        updates.push(`game_data = jsonb_set(game_data, '{reinforceStones}', to_jsonb((COALESCE((game_data->>'reinforceStones')::int, 0) + $` + idx + `)::int))`);
        vals.push(reward.reinforceStones); idx++;
      }
      if (reward.refinementStones) {
        updates.push(`game_data = jsonb_set(game_data, '{refinementStones}', to_jsonb((COALESCE((game_data->>'refinementStones')::int, 0) + $` + idx + `)::int))`);
        vals.push(reward.refinementStones); idx++;
      }
      if (reward.petEssence) {
        updates.push(`game_data = jsonb_set(game_data, '{petEssence}', to_jsonb((COALESCE((game_data->>'petEssence')::int, 0) + $` + idx + `)::int))`);
        vals.push(reward.petEssence); idx++;
      }
      if (updates.length) {
        await pool.query('UPDATE players SET ' + updates.join(', ') + ' WHERE wallet = $1', vals);
      }
    }

    res.json({ ok: true, streak, reward });
  } catch (e) {
    res.status(500).json({ error: safeError(e) });
  }
});

// === 排行榜 ===
app.get('/api/leaderboard/:type', async (req, res) => {
  try {
    const { type } = req.params;
    const typeMap = { power: 'combat_power', level: 'level', recharge: 'recharge' };
    const cacheType = typeMap[type];
    if (!cacheType) return res.status(400).json({ error: '无效排行类型' });

    // 优先读缓存
    const cached = await pool.query('SELECT data FROM leaderboard_cache WHERE type=$1', [cacheType]);
    if (cached.rows.length > 0 && cached.rows[0].data?.length > 0) {
      const data = cached.rows[0].data.map(r => ({
        ...r,
        wallet: r.wallet ? r.wallet.slice(0, 6) + '...' + r.wallet.slice(-4) : '',
        // 兼容前端字段名（优先用缓存中的真实值）
        combat_power: Number(r.combat_power ?? r.score) || 0,
        total_recharge: r.total_recharge ?? r.score,
        vip_level: r.vip_level || 0
      }));
      return res.json({ type, data });
    }

    // 缓存未命中，直接查询
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
    }
    const result = await pool.query(query);
    const data = result.rows.map((r, i) => ({
      rank: i + 1,
      ...r,
      wallet: r.wallet.slice(0, 6) + '...' + r.wallet.slice(-4)
    }));
    res.json({ type, data });
  } catch (e) {
    res.status(500).json({ error: safeError(e) });
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
    res.status(500).json({ error: safeError(e) });
  }
});

function sanitizePlayer(p) {
  // Recalc derived stats from equipment before sending to frontend
  if (!p.game_data || typeof p.game_data !== 'object') p.game_data = {};
  recalcDerivedStats(p.game_data);
  // M4-fix: spirit_stones column is SSOT, override game_data
  p.game_data.spiritStones = Number(p.spirit_stones) || 0;
  return {
    id: p.id, wallet: p.wallet, name: p.name, gameData: p.game_data,
    vipLevel: p.vip_level, totalRecharge: p.total_recharge,
    spiritStones: p.spirit_stones, level: p.level, realm: p.realm,
    combatPower: p.combat_power, firstRecharge: p.first_recharge,
    stateVersion: Number(p.state_version) || 0,
    dailySignDate: p.daily_sign_date ? (p.daily_sign_date instanceof Date ? p.daily_sign_date.toISOString().split("T")[0] : String(p.daily_sign_date).split("T")[0]) : null, dailySignStreak: p.daily_sign_streak
  };
}

// === 月卡系统 ===
const MONTHLY_CARD_PRICE = 10; // 10 ROON
const MONTHLY_CARD_DAILY = 5000; // 每日5000焰晶
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
    res.status(500).json({ error: safeError(e) });
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
    const pName = (await pool.query('SELECT name FROM players WHERE wallet=$1', [req.user.wallet])).rows[0]?.name || '无名焰修';
    if (app.locals.broadcastEvent) {
      app.locals.broadcastEvent(`💳 ${pName} 开通了月卡！`, 'monthlycard');
    }

    res.json({ ok: true, expiresAt, dailyReward: MONTHLY_CARD_DAILY });
  } catch (e) {
    res.status(500).json({ error: safeError(e) });
  }
});

// 领取月卡每日焰晶
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

    // 检查双倍卡
    const mcGd = await pool.query('SELECT game_data FROM players WHERE wallet=$1', [req.user.wallet]);
    const mcData = mcGd.rows[0]?.game_data || {};
    const mcStones = isBuffActive(mcData, 'doubleCrystal') ? MONTHLY_CARD_DAILY * 2 : MONTHLY_CARD_DAILY;
    await pool.query(
      `UPDATE players SET spirit_stones = spirit_stones + $1,
       game_data = jsonb_set(game_data, '{spiritStones}', to_jsonb((COALESCE((game_data->>'spiritStones')::bigint, 0) + $1)::bigint))
       WHERE wallet = $2`,
      [mcStones, req.user.wallet]
    );

    res.json({ ok: true, stones: MONTHLY_CARD_DAILY, daysClaimed: card.days_claimed + 1 });
  } catch (e) {
    res.status(500).json({ error: safeError(e) });
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
    res.status(500).json({ error: safeError(e) });
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
    res.status(500).json({ error: safeError(e) });
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
    // 发放焰晶
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
    res.status(500).json({ error: safeError(e) });
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
    res.status(500).json({ error: safeError(e) });
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
    res.status(500).json({ error: safeError(e) });
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
    res.status(500).json({ error: safeError(e) });
  }
});


// === 焰盟系统 ===
const SECT_LEVEL_EXP = [0, 1000, 3000, 8000, 20000, 50000, 100000, 200000, 500000, 1000000];
const SECT_TASK_POOL = {
  daily: [
    { title: '焰气采集', description: '采集天地焰气，为焰盟积蓄力量', reward_contribution: 10, reward_stones: 200 },
    { title: '巡山护法', description: '巡视焰盟山门，驱逐妖兽', reward_contribution: 15, reward_stones: 300 },
    { title: '阵法维护', description: '维护焰盟护山大阵', reward_contribution: 12, reward_stones: 250 },
    { title: '丹药炼制', description: '为焰盟炼制基础焰丹', reward_contribution: 20, reward_stones: 400 },
    { title: '弟子指导', description: '指导新入门弟子修炼', reward_contribution: 8, reward_stones: 150 },
    { title: '焰田耕种', description: '打理焰盟焰田', reward_contribution: 10, reward_stones: 200 },
  ],
  weekly: [
    { title: '秘境探索', description: '探索焰盟秘境，寻找珍稀资源', reward_contribution: 50, reward_stones: 1500 },
    { title: '焰盟大比', description: '参加焰盟内部切磋大比', reward_contribution: 80, reward_stones: 2000 },
    { title: '妖兽讨伐', description: '讨伐威胁焰盟的强大妖兽', reward_contribution: 60, reward_stones: 1800 },
    { title: '资源运送', description: '护送珍贵资源回焰盟', reward_contribution: 70, reward_stones: 2500 },
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
    if (!name || name.length < 2 || name.length > 20) return res.status(400).json({ error: '焰盟名称2-20字' });
    const existing = await pool.query('SELECT id FROM sect_members WHERE wallet=$1', [req.user.wallet]);
    if (existing.rows.length > 0) return res.status(400).json({ error: '你已加入焰盟' });
    const player = await pool.query('SELECT spirit_stones, game_data FROM players WHERE wallet=$1', [req.user.wallet]);
    if (!player.rows.length) return res.status(400).json({ error: '玩家不存在' });
    const gameData = typeof player.rows[0].game_data === 'string' ? JSON.parse(player.rows[0].game_data) : player.rows[0].game_data;
    const stones = gameData?.spiritStones ?? player.rows[0].spirit_stones ?? 0;
    if (stones < 50000) return res.status(400).json({ error: '焰晶不足，需要50000焰晶' });
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
    if (e.code === '23505') return res.status(400).json({ error: '焰盟名称已存在' });
    res.status(500).json({ error: safeError(e) });
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
  } catch (e) { res.status(500).json({ error: safeError(e) }); }
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
  } catch (e) { res.status(500).json({ error: safeError(e) }); }
});

// POST /api/sect/join
app.post('/api/sect/join', auth, async (req, res) => {
  try {
    const { sectId } = req.body;
    if (!sectId || isNaN(parseInt(sectId))) return res.status(400).json({ error: '无效的焰盟ID' });
    const existing = await pool.query('SELECT id FROM sect_members WHERE wallet=$1', [req.user.wallet]);
    if (existing.rows.length > 0) return res.status(400).json({ error: '你已加入焰盟' });
    const sect = await pool.query('SELECT * FROM sects WHERE id=$1', [sectId]);
    if (!sect.rows.length) return res.status(400).json({ error: '焰盟不存在' });
    const count = await pool.query('SELECT COUNT(*) FROM sect_members WHERE sect_id=$1', [sectId]);
    if (parseInt(count.rows[0].count) >= sect.rows[0].max_members) return res.status(400).json({ error: '焰盟已满' });
    await pool.query('INSERT INTO sect_members (sect_id, wallet, role) VALUES ($1,$2,$3)', [sectId, req.user.wallet, 'member']);
    res.json({ ok: true });
  } catch (e) { res.status(500).json({ error: safeError(e) }); }
});

// POST /api/sect/leave
app.post('/api/sect/leave', auth, async (req, res) => {
  try {
    const mem = await pool.query('SELECT * FROM sect_members WHERE wallet=$1', [req.user.wallet]);
    if (!mem.rows.length) return res.status(400).json({ error: '你未加入焰盟' });
    if (mem.rows[0].role === 'leader') return res.status(400).json({ error: '掌门不能退出，请先转让掌门' });
    await pool.query('DELETE FROM sect_members WHERE wallet=$1', [req.user.wallet]);
    res.json({ ok: true });
  } catch (e) { res.status(500).json({ error: safeError(e) }); }
});

// POST /api/sect/kick
app.post('/api/sect/kick', auth, async (req, res) => {
  try {
    const { wallet } = req.body;
    const me = await pool.query('SELECT * FROM sect_members WHERE wallet=$1', [req.user.wallet]);
    if (!me.rows.length || (me.rows[0].role !== 'leader' && me.rows[0].role !== 'elder')) return res.status(403).json({ error: '权限不足' });
    const target = await pool.query('SELECT * FROM sect_members WHERE wallet=$1 AND sect_id=$2', [wallet, me.rows[0].sect_id]);
    if (!target.rows.length) return res.status(400).json({ error: '该玩家不在焰盟中' });
    if (target.rows[0].role === 'leader') return res.status(400).json({ error: '不能踢掌门' });
    if (me.rows[0].role === 'elder' && target.rows[0].role === 'elder') return res.status(400).json({ error: '长老不能踢长老' });
    await pool.query('DELETE FROM sect_members WHERE wallet=$1', [wallet]);
    res.json({ ok: true });
  } catch (e) { res.status(500).json({ error: safeError(e) }); }
});

// POST /api/sect/promote
app.post('/api/sect/promote', auth, async (req, res) => {
  try {
    const { wallet } = req.body;
    const me = await pool.query('SELECT * FROM sect_members WHERE wallet=$1', [req.user.wallet]);
    if (!me.rows.length || me.rows[0].role !== 'leader') return res.status(403).json({ error: '只有掌门可以升职' });
    const target = await pool.query('SELECT * FROM sect_members WHERE wallet=$1 AND sect_id=$2', [wallet, me.rows[0].sect_id]);
    if (!target.rows.length) return res.status(400).json({ error: '该玩家不在焰盟中' });
    if (target.rows[0].role === 'leader') return res.status(400).json({ error: '已是掌门' });
    if (target.rows[0].role === 'elder') return res.status(400).json({ error: '已是长老' });
    await pool.query('UPDATE sect_members SET role=$1 WHERE wallet=$2', ['elder', wallet]);
    res.json({ ok: true });
  } catch (e) { res.status(500).json({ error: safeError(e) }); }
});

// POST /api/sect/demote
app.post('/api/sect/demote', auth, async (req, res) => {
  try {
    const { wallet } = req.body;
    const me = await pool.query('SELECT * FROM sect_members WHERE wallet=$1', [req.user.wallet]);
    if (!me.rows.length || me.rows[0].role !== 'leader') return res.status(403).json({ error: '只有掌门可以降职' });
    const target = await pool.query('SELECT * FROM sect_members WHERE wallet=$1 AND sect_id=$2', [wallet, me.rows[0].sect_id]);
    if (!target.rows.length) return res.status(400).json({ error: '该玩家不在焰盟中' });
    if (target.rows[0].role !== 'elder') return res.status(400).json({ error: '只能降职长老' });
    await pool.query('UPDATE sect_members SET role=$1 WHERE wallet=$2', ['member', wallet]);
    res.json({ ok: true });
  } catch (e) { res.status(500).json({ error: safeError(e) }); }
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
  } catch (e) { res.status(500).json({ error: safeError(e) }); }
});

// GET /api/sect/tasks
app.get('/api/sect/tasks', auth, async (req, res) => {
  try {
    const mem = await pool.query('SELECT * FROM sect_members WHERE wallet=$1', [req.user.wallet]);
    if (!mem.rows.length) return res.status(400).json({ error: '你未加入焰盟' });
    await ensureSectTasks(mem.rows[0].sect_id);
    const tasks = await pool.query('SELECT * FROM sect_tasks WHERE sect_id=$1 ORDER BY type, id', [mem.rows[0].sect_id]);
    res.json({ tasks: tasks.rows });
  } catch (e) { res.status(500).json({ error: safeError(e) }); }
});

// POST /api/sect/tasks/:id/complete
app.post('/api/sect/tasks/:id/complete', auth, async (req, res) => {
  try {
    const taskId = req.params.id;
    const mem = await pool.query('SELECT * FROM sect_members WHERE wallet=$1', [req.user.wallet]);
    if (!mem.rows.length) return res.status(400).json({ error: '你未加入焰盟' });
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
    let taskStones = task.rows[0].reward_stones;
    if (isBuffActive(gameData, 'doubleCrystal')) taskStones *= 2;
    gameData.spiritStones = (gameData.spiritStones || 0) + taskStones;
    await pool.query('UPDATE players SET game_data=$1, spirit_stones=$2 WHERE wallet=$3',
      [JSON.stringify(gameData), gameData.spiritStones, req.user.wallet]);
    res.json({ ok: true, reward_contribution: task.rows[0].reward_contribution, reward_stones: taskStones });
  } catch (e) { res.status(500).json({ error: safeError(e) }); }
});

// POST /api/sect/donate
app.post('/api/sect/donate', auth, async (req, res) => {
  try {
    const { amount } = req.body;
    if (!amount || amount < 100) return res.status(400).json({ error: '最少捐献100焰晶' });
    const mem = await pool.query('SELECT * FROM sect_members WHERE wallet=$1', [req.user.wallet]);
    if (!mem.rows.length) return res.status(400).json({ error: '你未加入焰盟' });
    const player = await pool.query('SELECT game_data FROM players WHERE wallet=$1', [req.user.wallet]);
    const gameData = typeof player.rows[0].game_data === 'string' ? JSON.parse(player.rows[0].game_data) : player.rows[0].game_data;
    const stones = gameData?.spiritStones ?? 0;
    if (stones < amount) return res.status(400).json({ error: '焰晶不足' });
    gameData.spiritStones = stones - amount;
    await pool.query('UPDATE players SET game_data=$1, spirit_stones=$2 WHERE wallet=$3',
      [JSON.stringify(gameData), gameData.spiritStones, req.user.wallet]);
    const contribution = Math.floor(amount / 10);
    await pool.query('UPDATE sect_members SET contribution=contribution+$1 WHERE wallet=$2', [contribution, req.user.wallet]);
    await pool.query('UPDATE sects SET exp=exp+$1 WHERE id=$2', [amount, mem.rows[0].sect_id]);
    await checkSectLevelUp(mem.rows[0].sect_id);
    res.json({ ok: true, contribution, exp: amount });
  } catch (e) { res.status(500).json({ error: safeError(e) }); }
});

// GET /api/sect/members
app.get('/api/sect/members', auth, async (req, res) => {
  try {
    const { sectId } = req.query;
    const id = sectId || (await pool.query('SELECT sect_id FROM sect_members WHERE wallet=$1', [req.user.wallet])).rows[0]?.sect_id;
    if (!id) return res.status(400).json({ error: '未指定焰盟' });
    const members = await pool.query(
      `SELECT sm.wallet, sm.role, sm.contribution, sm.joined_at, p.name, p.level, p.realm, p.combat_power
       FROM sect_members sm LEFT JOIN players p ON sm.wallet = p.wallet WHERE sm.sect_id=$1 ORDER BY sm.role='leader' DESC, sm.role='elder' DESC, sm.contribution DESC`,
      [id]
    );
    res.json({ members: members.rows });
  } catch (e) { res.status(500).json({ error: safeError(e) }); }
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
const PK_REWARD = 500; // 胜者奖励焰晶
let pkIdCounter = 0;

function getWsByWallet(wallet) {
  for (const [ws, info] of onlineClients) {
    if (info.wallet === wallet) return ws;
  }
  return null;
}

function runPkBattle(statsA, statsB) {
  // Full combat with all attributes
  const calcDmg = (atk, def) => {
    let dmg = atk.attack * (100 / (100 + def.defense));
    // combatBoost: overall damage multiplier
    dmg *= 1 + (atk.combatBoost || 0);
    // finalDamageBoost: attacker's final damage increase
    dmg *= 1 + (atk.finalDamageBoost || 0);
    let isCrit = Math.random() < (atk.critRate || 0.05);
    let isCombo = Math.random() < (atk.comboRate || 0);
    // dodgeRate reduced by dodgeResist
    const effectiveDodge = Math.max(0, (def.dodgeRate || 0.05) - (atk.dodgeResist || 0));
    let isDodged = Math.random() < effectiveDodge;
    if (isCrit) {
      let critMult = 1.5 + (atk.critDamageBoost || 0);
      // critDamageReduce: defender reduces crit damage
      critMult -= (def.critDamageReduce || 0);
      dmg *= Math.max(1.1, critMult);
    }
    if (isCombo) dmg *= 1.3;
    // finalDamageReduce: defender's final damage reduction
    dmg *= 1 - Math.min(0.7, (def.finalDamageReduce || 0));
    // resistanceBoost: defender's overall resistance
    dmg *= 1 - Math.min(0.3, (def.resistanceBoost || 0));
    return { damage: Math.max(1, Math.floor(dmg)), isCrit, isCombo, isDodged };
  };

  let hpA = statsA.health, hpB = statsB.health;
  const maxHpA = hpA, maxHpB = hpB;
  const rounds = [];
  const maxRounds = 15;

  for (let i = 0; i < maxRounds && hpA > 0 && hpB > 0; i++) {
    const r = { round: i + 1, actions: [] };
    const first = (statsA.speed || 10) >= (statsB.speed || 10) ? 'A' : 'B';
    const order = first === 'A' ? [['A', statsA, statsB], ['B', statsB, statsA]] : [['B', statsB, statsA], ['A', statsA, statsB]];

    for (const [side, atk, def] of order) {
      const atkHp = side === 'A' ? hpA : hpB;
      if (atkHp <= 0) break;
      const hit = calcDmg(atk, def);
      if (hit.isDodged) {
        r.actions.push({ attacker: side, isDodged: true, damage: 0, isCrit: false, isCombo: false });
      } else {
        if (side === 'A') hpB = Math.max(0, hpB - hit.damage);
        else hpA = Math.max(0, hpA - hit.damage);
        r.actions.push({ attacker: side, damage: hit.damage, isCrit: hit.isCrit, isCombo: hit.isCombo, isDodged: false });
        // vampireRate: lifesteal (reduced by vampireResist)
        const effectiveVampire = Math.max(0, (atk.vampireRate || 0) - (def.vampireResist || 0));
        if (effectiveVampire > 0) {
          const heal = Math.floor(hit.damage * effectiveVampire);
          if (side === 'A') hpA = Math.min(maxHpA, hpA + heal);
          else hpB = Math.min(maxHpB, hpB + heal);
        }
        // counterRate: defender counter-attacks (reduced by counterResist)
        const effectiveCounter = Math.max(0, (def.counterRate || 0) - (atk.counterResist || 0));
        if (effectiveCounter > 0 && Math.random() < effectiveCounter) {
          const counterDmg = Math.max(1, Math.floor(def.attack * 0.5 * (100 / (100 + atk.defense))));
          if (side === 'A') hpA = Math.max(0, hpA - counterDmg);
          else hpB = Math.max(0, hpB - counterDmg);
          r.actions.push({ attacker: side === 'A' ? 'B' : 'A', damage: counterDmg, isCounter: true });
        }
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
  wss.clients.forEach(c => { try { if (c.readyState === 1) c.send(msg); } catch(e) {} });
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
  // 连接数限制
  if (wss.clients.size > 200) {
    ws.close(1013, 'Server too busy');
    return;
  }
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
          userInfo = { wallet: decoded.wallet, name: data.name || '无名焰修' };
          onlineClients.set(ws, userInfo);
          broadcast({ type: 'online', count: wss.clients.size });
          broadcastEvent(`${userInfo.name} 进入了焰域`, 'join');
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
        userInfo.realm = data.realm || '燃火一层';
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
              realm: info.realm || '燃火一层',
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
          fromName: userInfo.name, toName: onlineClients.get(targetWs)?.name || '无名焰修',
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

        // 从DB读取双方真实属性（不信任前端上报）
        const [playerAData, playerBData] = await Promise.all([
          getPlayerFinalStats(pool, challenge.from),
          getPlayerFinalStats(pool, userInfo.wallet)
        ]);
        if (!playerAData || !playerBData) {
          return ws.send(JSON.stringify({ type: 'pk_error', msg: '无法获取玩家数据' }));
        }
        const statsA = playerAData.finalStats;
        const statsB = playerBData.finalStats;

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
          broadcastEvent(`${winnerName} 在切磋中击败了 ${result.winner === 'A' ? challenge.toName : challenge.fromName}，获得 ${PK_REWARD} 焰晶！`, 'pk');
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
          maxHpA: statsA.health, maxHpB: statsB.health,
          state_version_a: playerAData.stateVersion,
          state_version_b: playerBData.stateVersion
        };
        // 记录战斗日志
        logBattleTrace(pool, {
          battleType: 'pk', walletA: challenge.from, walletB: userInfo.wallet,
          versionA: playerAData.stateVersion, versionB: playerBData.stateVersion,
          statsA, statsB, result: { winner: result.winner, rounds: result.rounds.length }
        });

        fromWs.send(JSON.stringify(battleResult));
        ws.send(JSON.stringify(battleResult));
      }

      
      // 私聊消息
      if (data.type === 'private_chat') {
        if (!userInfo) return;
        const text = (data.text || '').trim().slice(0, 500);
        if (!text || !data.toWallet) return;

        // 验证好友关系
        const friendCheck = await pool.query(
          "SELECT id FROM friendships WHERE status='accepted' AND ((from_wallet=$1 AND to_wallet=$2) OR (from_wallet=$2 AND to_wallet=$1))",
          [userInfo.wallet, data.toWallet]
        );
        if (friendCheck.rows.length === 0) {
          ws.send(JSON.stringify({ type: 'error', message: '只能给好友发送私聊消息' }));
          return;
        }

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
  } catch (e) { res.status(500).json({ error: safeError(e) }); }
});

// GET /api/friend/unread - 获取未读消息计数（按发送者分组）
app.get('/api/friend/unread', auth, async (req, res) => {
  try {
    const rows = await pool.query(
      `SELECT from_wallet, COUNT(*)::int as count FROM private_messages WHERE to_wallet=$1 AND is_read=false GROUP BY from_wallet`,
      [req.user.wallet]
    );
    res.json({ ok: true, unread: rows.rows });
  } catch (e) { res.status(500).json({ error: safeError(e) }); }
});

// === Admin 活动管理 ===
const ADMIN_WALLETS = (process.env.ADMIN_WALLETS || "0xfad7eb0814b6838b05191a07fb987957d50c4ca9,0x82e402b05f3e936b63a874788c73e1552657c4f7").toLowerCase().split(",").map(function(w){return w.trim()});
const adminAuth = async (req, res, next) => {
  if (!req.user) return res.status(401).json({ error: "未登录" });
  if (!ADMIN_WALLETS.includes(req.user.wallet.toLowerCase())) return res.status(403).json({ error: "无权限" });
  next();
};

// GET /api/admin/events - 获取所有活动
app.get("/api/admin/events", auth, adminAuth, async (req, res) => {
  try {
    const result = await pool.query("SELECT * FROM events ORDER BY created_at DESC");
    res.json({ events: result.rows });
  } catch (e) { res.status(500).json({ error: safeError(e) }); }
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
  } catch (e) { res.status(500).json({ error: safeError(e) }); }
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
  } catch (e) { res.status(500).json({ error: safeError(e) }); }
});

// DELETE /api/admin/events/:id - 删除活动
app.delete("/api/admin/events/:id", auth, adminAuth, async (req, res) => {
  try {
    await pool.query("DELETE FROM event_claims WHERE event_id=$1", [req.params.id]);
    const result = await pool.query("DELETE FROM events WHERE id=$1 RETURNING id", [req.params.id]);
    if (!result.rows.length) return res.status(404).json({ error: "活动不存在" });
    res.json({ ok: true });
  } catch (e) { res.status(500).json({ error: safeError(e) }); }
});

// GET /api/admin/events/:id/claims - 查看领取记录
app.get("/api/admin/events/:id/claims", auth, adminAuth, async (req, res) => {
  try {
    const result = await pool.query(
      `SELECT ec.id, ec.wallet, ec.claimed_at, p.name FROM event_claims ec LEFT JOIN players p ON ec.wallet = p.wallet WHERE ec.event_id=$1 ORDER BY ec.claimed_at DESC`,
      [req.params.id]
    );
    res.json({ claims: result.rows });
  } catch (e) { res.status(500).json({ error: safeError(e) }); }
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
  } catch (e) { res.status(500).json({ error: safeError(e) }); }
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
      // 同时发邮件通知
      const bossName2 = boss.rows[0]?.name || '世界Boss';
      await pool.query(
        'INSERT INTO player_mail (to_wallet, from_type, from_name, title, content, rewards) VALUES ($1, $2, $3, $4, $5, $6)',
        [rows[i].wallet, 'system', '系统', '世界Boss击杀奖励', '恭喜您在' + bossName2 + '的战斗中排名第' + rank + '名！奖励已发放。', JSON.stringify({spiritStones: stones})]
      );
    }
    const boss = await pool.query('SELECT name FROM world_bosses WHERE id = $1', [bossId]);
    const topDamagers = rows.slice(0, 5).map((r, i) => ({
      rank: i + 1, name: r.player_name, damage: Number(r.damage)
    }));
    const killerName = rows.length > 0 ? rows[0].player_name : '无名焰修';
    broadcast({ type: 'boss_dead', data: { bossName: boss.rows[0]?.name, killerName, topDamagers } });
    broadcastEvent(`🐉 世界Boss ${boss.rows[0]?.name} 已被击杀！最大功臣: ${killerName}`, 'boss');
  } catch (e) {
    logger.error('Boss reward settlement error:', e);
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
  } catch (e) { res.status(500).json({ error: safeError(e) }); }
});

// POST /api/boss/attack
app.post('/api/boss/attack', auth, idempotent(pool, 'boss_attack'), async (req, res) => {
  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    const wallet = req.user.wallet;
    const now = Date.now();
    const lastAtk = bossAttackCooldown.get(wallet) || 0;
    if (now - lastAtk < 3000) {
      await client.query('ROLLBACK');
      return res.status(400).json({ error: `冷却中，${Math.ceil((3000 - (now - lastAtk)) / 1000)}秒后再试` });
    }
    const boss = await client.query(
      "SELECT * FROM world_bosses WHERE status = 'active' ORDER BY spawn_time DESC LIMIT 1"
    );
    if (boss.rows.length === 0) { await client.query('ROLLBACK'); return res.status(400).json({ error: '当前没有世界Boss' }); }
    const b = boss.rows[0];
    if (Number(b.current_hp) <= 0) { await client.query('ROLLBACK'); return res.status(400).json({ error: 'Boss已被击杀' }); }
    const player = await client.query('SELECT * FROM players WHERE wallet = $1', [wallet]);
    if (!player.rows.length) { await client.query('ROLLBACK'); return res.status(400).json({ error: '玩家不存在' }); }
    const p = player.rows[0];
    const gameData = typeof p.game_data === 'string' ? JSON.parse(p.game_data) : (p.game_data || {});
    const spirit = gameData.spirit || 0;
    if (spirit < 10) { await client.query('ROLLBACK'); return res.status(400).json({ error: '灵力不足，需要10灵力' }); }
    gameData.spirit = spirit - 10;
    // 使用 stats-service 计算最终属性
    const bonuses = await getMountTitleBonuses(client, wallet);
    const finalStats = computeFinalStats(gameData, bonuses);
    const pAtk = finalStats.attack;
    const critRate = finalStats.critRate || 0.05;
    const comboRate = finalStats.comboRate || 0;
    const isCrit = Math.random() < critRate;
    const isCombo = Math.random() < comboRate;
    let damage = Math.max(1, Math.floor(pAtk * (100 / (100 + b.defense)) * (0.9 + Math.random() * 0.2)));
    // combatBoost & finalDamageBoost
    damage *= 1 + (finalStats.combatBoost || 0);
    damage *= 1 + (finalStats.finalDamageBoost || 0);
    if (isCrit) damage = Math.floor(damage * (1.5 + (finalStats.critDamageBoost || 0)));
    if (isCombo) damage = Math.floor(damage * 1.3);
    damage = Math.max(1, Math.floor(damage));
    const newHp = Math.max(0, Number(b.current_hp) - damage);
    await client.query('UPDATE world_bosses SET current_hp = $1 WHERE id = $2', [newHp, b.id]);
    const newVersion = (Number(p.state_version) || 0) + 1;
    await client.query('UPDATE players SET game_data = $1, state_version = $2 WHERE wallet = $3', [JSON.stringify(gameData), newVersion, wallet]);
    await client.query(
      `INSERT INTO boss_damage_log (boss_id, wallet, player_name, damage, attacks_count, last_attack_at)
       VALUES ($1, $2, $3, $4, 1, NOW())
       ON CONFLICT (boss_id, wallet) DO UPDATE SET
         damage = boss_damage_log.damage + $4,
         attacks_count = boss_damage_log.attacks_count + 1,
         player_name = $3,
         last_attack_at = NOW()`,
      [b.id, wallet, p.name || '无名焰修', damage]
    );
    bossAttackCooldown.set(wallet, now);
    const myTotal = await client.query(
      'SELECT damage FROM boss_damage_log WHERE boss_id = $1 AND wallet = $2', [b.id, wallet]
    );
    await client.query('COMMIT');
    broadcast({
      type: 'boss_hit',
      data: {
        playerName: p.name || '无名焰修',
        damage, isCrit,
        bossHp: newHp, bossMaxHp: Number(b.max_hp)
      }
    });
    if (newHp <= 0) {
      await pool.query("UPDATE world_bosses SET status = 'dead', death_time = NOW() WHERE id = $1", [b.id]);
      await settleBossRewards(b.id);
    }
    // 记录战斗日志
    logBattleTrace(pool, {
      battleType: 'boss', walletA: wallet, walletB: null,
      versionA: newVersion, versionB: null,
      statsA: finalStats, statsB: { hp: Number(b.current_hp), defense: b.defense },
      result: { damage, isCrit, bossHp: newHp }
    });
    res.json({
      damage, isCrit,
      bossHp: newHp, bossMaxHp: Number(b.max_hp),
      myTotalDamage: Number(myTotal.rows[0]?.damage || damage),
      spirit: gameData.spirit,
      state_version: newVersion
    });
  } catch (e) {
    await client.query('ROLLBACK').catch(() => {});
    res.status(500).json({ error: e.message || '服务器错误' });
  } finally {
    client.release();
  }
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
  } catch (e) { res.status(500).json({ error: safeError(e) }); }
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
  } catch (e) { res.status(500).json({ error: safeError(e) }); }
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
    // 双倍卡buff
    if (isBuffActive(gameData, 'doubleCrystal')) totalStones *= 2;
    gameData.spiritStones = (gameData.spiritStones || 0) + totalStones;
    await pool.query('UPDATE players SET game_data = $1, spirit_stones = $2 WHERE wallet = $3',
      [JSON.stringify(gameData), gameData.spiritStones, req.user.wallet]);
    res.json({ ok: true, totalStones, newSpiritStones: gameData.spiritStones });
  } catch (e) { res.status(500).json({ error: safeError(e) }); }
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
  } catch (e) { res.status(500).json({ error: safeError(e) }); }
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
    broadcastEvent(`🐉 世界Boss【${b.name}】降临了！全体焰修者准备讨伐！`, 'boss');
    res.json({ ok: true, boss: b });
  } catch (e) { res.status(500).json({ error: safeError(e) }); }
});

// GET /api/admin/boss/list
app.get('/api/admin/boss/list', auth, adminAuth, async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM world_bosses ORDER BY created_at DESC');
    res.json({ bosses: result.rows });
  } catch (e) { res.status(500).json({ error: safeError(e) }); }
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
  } catch (e) { res.status(500).json({ error: safeError(e) }); }
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
  } catch (e) { res.status(500).json({ error: safeError(e) }); }
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
  } catch (e) { res.status(500).json({ error: safeError(e) }); }
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
      wallet: player.wallet, name: player.name || "无名焰修", level: player.level || 1,
      realm: player.realm || "燃火期一层", combatPower: Number(player.combat_power || 0),
      vipLevel: player.vip_level || 0, equippedArtifacts,
      sect: sect.rows.length ? { name: sect.rows[0].sect_name, role: sect.rows[0].role } : null
    }});
  } catch (e) { res.status(500).json({ error: safeError(e) }); }
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
      if (stones < gift_value) return res.status(400).json({ error: "焰晶不足" });
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
  } catch (e) { res.status(500).json({ error: safeError(e) }); }
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
      id: r.id, fromWallet: r.from_wallet, fromName: r.name || "无名焰修",
      giftType: r.gift_type, giftValue: r.gift_value, message: r.message,
      claimed: r.claimed, createdAt: r.created_at
    })) });
  } catch (e) { res.status(500).json({ error: safeError(e) }); }
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
  } catch (e) { res.status(500).json({ error: safeError(e) }); }
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
      name: r.name || "无名焰修",
      level: r.level || 1,
      realm: r.realm || "燃火期一层",
      combatPower: Number(r.combat_power || 0),
      online: r.updated_at ? (now - new Date(r.updated_at).getTime() < 5 * 60 * 1000) : false
    }));
    res.json({ ok: true, friends, count: friends.length, max: 50 });
  } catch (e) { res.status(500).json({ error: safeError(e) }); }
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
      id: r.id, wallet: r.from_wallet, name: r.name || "无名焰修",
      level: r.level || 1, realm: r.realm || "燃火期一层",
      combatPower: Number(r.combat_power || 0), createdAt: r.created_at
    })) });
  } catch (e) { res.status(500).json({ error: safeError(e) }); }
});

// POST /api/friend/search - 搜索玩家
app.post("/api/friend/search", auth, async (req, res) => {
  try {
    const { keyword } = req.body;
    if (!keyword || keyword.trim().length < 1) return res.status(400).json({ error: "请输入搜索关键词" });
    const result = await pool.query(
      `SELECT wallet, name, level, realm, combat_power FROM players
       WHERE (name ILIKE $1 OR wallet ILIKE $1) AND wallet != $2 LIMIT 20`,
      ["%" + keyword.trim() + "%", req.user.wallet]
    );
    const friendsRes = await pool.query(
      `SELECT CASE WHEN from_wallet=$1 THEN to_wallet ELSE from_wallet END as fw
       FROM friendships WHERE (from_wallet=$1 OR to_wallet=$1) AND status IN ($2,$3)`,
      [req.user.wallet, "accepted", "pending"]
    );
    const friendSet = new Set(friendsRes.rows.map(r => r.fw));
    res.json({ ok: true, players: result.rows.map(r => ({
      wallet: r.wallet, name: r.name || "无名焰修", level: r.level || 1,
      realm: r.realm || "燃火期一层", combatPower: Number(r.combat_power || 0),
      isFriend: friendSet.has(r.wallet)
    })) });
  } catch (e) { res.status(500).json({ error: safeError(e) }); }
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
  } catch (e) { res.status(500).json({ error: safeError(e) }); }
});

// ============ 焰盟战系统 ============

// POST /api/sect-war/challenge - 发起焰盟战
app.post('/api/sect-war/challenge', auth, async (req, res) => {
  try {
    const { defender_sect_id } = req.body;
    const w = req.user.wallet;
    if (!defender_sect_id) return res.status(400).json({ error: '缺少参数' });

    // 检查身份：掌门或长老
    const mem = await pool.query('SELECT sect_id, role FROM sect_members WHERE wallet=$1', [w]);
    if (!mem.rows.length) return res.status(400).json({ error: '你还没有加入焰盟' });
    const { sect_id, role } = mem.rows[0];
    if (role !== 'leader' && role !== 'elder') return res.status(400).json({ error: '只有掌门或长老才能发起焰盟战' });

    if (sect_id === defender_sect_id) return res.status(400).json({ error: '不能挑战自己的焰盟' });

    // 对方焰盟至少3人
    const defCount = await pool.query('SELECT COUNT(*) FROM sect_members WHERE sect_id=$1', [defender_sect_id]);
    if (parseInt(defCount.rows[0].count) < 3) return res.status(400).json({ error: '对方焰盟人数不足3人，无法挑战' });

    // 己方焰盟至少3人
    const myCount = await pool.query('SELECT COUNT(*) FROM sect_members WHERE sect_id=$1', [sect_id]);
    if (parseInt(myCount.rows[0].count) < 3) return res.status(400).json({ error: '本焰盟人数不足3人，无法发起挑战' });

    // 每天最多3次
    const today = new Date(); today.setHours(0,0,0,0);
    const dailyCount = await pool.query(
      'SELECT COUNT(*) FROM sect_wars WHERE challenger_sect_id=$1 AND created_at >= $2',
      [sect_id, today]
    );
    if (parseInt(dailyCount.rows[0].count) >= 3) return res.status(400).json({ error: '今日挑战次数已用完(3/3)' });

    // 检查是否有进行中的焰盟战
    const ongoing = await pool.query(
      "SELECT id FROM sect_wars WHERE (challenger_sect_id=$1 OR defender_sect_id=$1) AND status IN ('pending','in_progress')",
      [sect_id]
    );
    if (ongoing.rows.length > 0) return res.status(400).json({ error: '你的焰盟已有进行中的焰盟战' });

    const defOngoing = await pool.query(
      "SELECT id FROM sect_wars WHERE (challenger_sect_id=$1 OR defender_sect_id=$1) AND status IN ('pending','in_progress')",
      [defender_sect_id]
    );
    if (defOngoing.rows.length > 0) return res.status(400).json({ error: '对方焰盟已有进行中的焰盟战' });

    const war = await pool.query(
      'INSERT INTO sect_wars (challenger_sect_id, defender_sect_id, status) VALUES ($1,$2,$3) RETURNING *',
      [sect_id, defender_sect_id, 'pending']
    );
    res.json({ ok: true, war: war.rows[0] });
  } catch (e) { res.status(500).json({ error: safeError(e) }); }
});

// GET /api/sect-war/pending - 收到的焰盟战邀请
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
  } catch (e) { res.status(500).json({ error: safeError(e) }); }
});

// POST /api/sect-war/accept - 接受焰盟战
app.post('/api/sect-war/accept', auth, async (req, res) => {
  try {
    const { war_id } = req.body;
    const mem = await pool.query('SELECT sect_id, role FROM sect_members WHERE wallet=$1', [req.user.wallet]);
    if (!mem.rows.length) return res.status(400).json({ error: '你还没有加入焰盟' });
    if (mem.rows[0].role !== 'leader' && mem.rows[0].role !== 'elder')
      return res.status(400).json({ error: '只有掌门或长老才能接受挑战' });

    const war = await pool.query('SELECT * FROM sect_wars WHERE id=$1 AND status=$2', [war_id, 'pending']);
    if (!war.rows.length) return res.status(400).json({ error: '焰盟战不存在或已处理' });
    if (war.rows[0].defender_sect_id !== mem.rows[0].sect_id)
      return res.status(400).json({ error: '这不是你焰盟收到的挑战' });

    await pool.query("UPDATE sect_wars SET status='in_progress', started_at=NOW() WHERE id=$1", [war_id]);
    res.json({ ok: true, message: '已接受挑战，焰盟战开始！' });
  } catch (e) { res.status(500).json({ error: safeError(e) }); }
});

// POST /api/sect-war/decline - 拒绝焰盟战
app.post('/api/sect-war/decline', auth, async (req, res) => {
  try {
    const { war_id } = req.body;
    const mem = await pool.query('SELECT sect_id, role FROM sect_members WHERE wallet=$1', [req.user.wallet]);
    if (!mem.rows.length) return res.status(400).json({ error: '你还没有加入焰盟' });
    if (mem.rows[0].role !== 'leader' && mem.rows[0].role !== 'elder')
      return res.status(400).json({ error: '只有掌门或长老才能拒绝挑战' });

    const war = await pool.query('SELECT * FROM sect_wars WHERE id=$1 AND status=$2', [war_id, 'pending']);
    if (!war.rows.length) return res.status(400).json({ error: '焰盟战不存在或已处理' });
    if (war.rows[0].defender_sect_id !== mem.rows[0].sect_id)
      return res.status(400).json({ error: '这不是你焰盟收到的挑战' });

    await pool.query("UPDATE sect_wars SET status='finished', finished_at=NOW() WHERE id=$1", [war_id]);
    res.json({ ok: true, message: '已拒绝挑战' });
  } catch (e) { res.status(500).json({ error: safeError(e) }); }
});

// POST /api/sect-war/join - 报名参战
app.post('/api/sect-war/join', auth, async (req, res) => {
  try {
    const { war_id } = req.body;
    const w = req.user.wallet;
    const mem = await pool.query('SELECT sect_id FROM sect_members WHERE wallet=$1', [w]);
    if (!mem.rows.length) return res.status(400).json({ error: '你还没有加入焰盟' });
    const mySectId = mem.rows[0].sect_id;

    const war = await pool.query("SELECT * FROM sect_wars WHERE id=$1 AND status='in_progress'", [war_id]);
    if (!war.rows.length) return res.status(400).json({ error: '焰盟战不存在或未开始' });

    const warData = war.rows[0];
    if (mySectId !== warData.challenger_sect_id && mySectId !== warData.defender_sect_id)
      return res.status(400).json({ error: '你的焰盟不在这场焰盟战中' });

    // 检查是否已报名
    const existing = await pool.query('SELECT id FROM sect_war_participants WHERE war_id=$1 AND wallet=$2', [war_id, w]);
    if (existing.rows.length) return res.status(400).json({ error: '你已经报名了' });

    // 每方最多5人
    const count = await pool.query('SELECT COUNT(*) FROM sect_war_participants WHERE war_id=$1 AND sect_id=$2', [war_id, mySectId]);
    if (parseInt(count.rows[0].count) >= 5) return res.status(400).json({ error: '本方参战名额已满(5/5)' });

    // 检查是否已有rounds_data（战斗已开始）
    if (warData.rounds_data) return res.status(400).json({ error: '战斗已经开始，无法报名' });

    const player = await pool.query('SELECT name, combat_power FROM players WHERE wallet=$1', [w]);
    const pName = player.rows[0]?.name || '无名焰修';
    const cp = parseInt(player.rows[0]?.combat_power || 0);

    await pool.query(
      'INSERT INTO sect_war_participants (war_id, sect_id, wallet, player_name, combat_power) VALUES ($1,$2,$3,$4,$5)',
      [war_id, mySectId, w, pName, cp]
    );
    res.json({ ok: true, message: '报名成功！' });
  } catch (e) { res.status(500).json({ error: safeError(e) }); }
});

// POST /api/sect-war/start - 开始战斗
app.post('/api/sect-war/start', auth, async (req, res) => {
  try {
    const { war_id } = req.body;
    const w = req.user.wallet;
    const mem = await pool.query('SELECT sect_id, role FROM sect_members WHERE wallet=$1', [w]);
    if (!mem.rows.length) return res.status(400).json({ error: '你还没有加入焰盟' });
    if (mem.rows[0].role !== 'leader') return res.status(400).json({ error: '只有掌门才能开始战斗' });

    const war = await pool.query("SELECT * FROM sect_wars WHERE id=$1 AND status='in_progress'", [war_id]);
    if (!war.rows.length) return res.status(400).json({ error: '焰盟战不存在或状态不对' });
    const warData = war.rows[0];

    if (warData.challenger_sect_id !== mem.rows[0].sect_id && warData.defender_sect_id !== mem.rows[0].sect_id)
      return res.status(400).json({ error: '你不在这场焰盟战中' });
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
  } catch (e) { res.status(500).json({ error: safeError(e) }); }
});

// GET /api/sect-war/current - 当前进行中的焰盟战
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
  } catch (e) { res.status(500).json({ error: safeError(e) }); }
});

// GET /api/sect-war/history - 焰盟战历史
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
  } catch (e) { res.status(500).json({ error: safeError(e) }); }
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
  } catch (e) { res.status(500).json({ error: safeError(e) }); }
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
  } catch (e) { res.status(500).json({ error: safeError(e) }); }
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

    // 更新焰盟贡献
    const mem = await pool.query('SELECT sect_id FROM sect_members WHERE wallet=$1', [w]);
    if (mem.rows.length) {
      await pool.query('UPDATE sect_members SET contribution = contribution + $1 WHERE wallet=$2', [totalContrib, w]);
    }

    res.json({ ok: true, stones: totalStones, contribution: totalContrib, message: `领取了 ${totalStones} 焰晶和 ${totalContrib} 贡献度` });
  } catch (e) { res.status(500).json({ error: safeError(e) }); }
});

// ============ 焰盟战系统结束 ============

// ============ 拍卖行系统 ============

// 过期处理函数
async function processExpiredAuctions() {
  try {
    const expired = await pool.query(
      "SELECT * FROM auction_listings WHERE status='active' AND expires_at < NOW()"
    );
    for (const listing of expired.rows) {
      if (listing.current_bid > 0 && listing.current_bidder) {
        // 有出价：物品给最高出价者，焰晶给卖家（扣5%手续费）
        const fee = Math.floor(listing.current_bid * 0.05);
        const sellerGets = listing.current_bid - fee;
        // 物品给买家
        await pool.query(
          `UPDATE players SET game_data = jsonb_set(game_data, '{items}', COALESCE(game_data->'items', '[]'::jsonb) || $1::jsonb) WHERE wallet = $2`,
          [JSON.stringify([listing.item_data]), listing.current_bidder]
        );
        // 焰晶给卖家
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
  } catch (e) { logger.error('processExpiredAuctions error:', e.message); }
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
    const playerName = player.rows[0].name || '无名焰修';
    const items = gd.items || [];
    const itemIndex = items.findIndex(i => String(i.id) === String(item_id));
    if (itemIndex === -1) return res.status(400).json({ error: '物品不存在' });

    const item = items[itemIndex];

    // 检查是否已装备
    const equipped = gd.equippedArtifacts || {};
    const equippedIds = Object.values(equipped).filter(Boolean).map(e => e.id);
    if (equippedIds.map(String).includes(String(item_id))) return res.status(400).json({ error: '已装备的物品不能上架' });

    // 上架费 5%
    const listingFee = Math.max(1, Math.floor(starting_price * 0.05));
    const stones = parseInt(gd.spiritStones) || 0;
    if (stones < listingFee) return res.status(400).json({ error: `焰晶不足，上架费需要 ${listingFee} 焰晶` });

    // 扣焰晶 + 移除物品
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

    res.json({ ok: true, message: `${item.name} 已上架，扣除上架费 ${listingFee} 焰晶`, spiritStones: newStones });
  } catch (e) { res.status(500).json({ error: safeError(e) }); }
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
  } catch (e) { res.status(500).json({ error: safeError(e) }); }
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
  } catch (e) { res.status(500).json({ error: safeError(e) }); }
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
    if (amount < minBid) { await client.query('ROLLBACK'); return res.status(400).json({ error: `出价至少为 ${minBid} 焰晶` }); }

    const player = await client.query('SELECT game_data FROM players WHERE wallet=$1 FOR UPDATE', [w]);
    const gd = player.rows[0].game_data;
    const stones = parseInt(gd.spiritStones) || 0;
    if (stones < amount) { await client.query('ROLLBACK'); return res.status(400).json({ error: '焰晶不足' }); }

    const playerNameRes = await client.query('SELECT name FROM players WHERE wallet=$1', [w]);
    const bidderName = playerNameRes.rows[0]?.name || '无名焰修';

    // 退还上一个出价者
    if (l.current_bidder && l.current_bid > 0) {
      await client.query(
        `UPDATE players SET game_data = jsonb_set(game_data, '{spiritStones}', to_jsonb(GREATEST(0, (COALESCE(game_data->>'spiritStones','0'))::int + $1))),
         spirit_stones = spirit_stones + $1 WHERE wallet = $2`,
        [l.current_bid, l.current_bidder]
      );
    }

    // 扣除出价者焰晶
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
    res.json({ ok: true, message: `出价 ${amount} 焰晶成功` });
  } catch (e) { await client.query('ROLLBACK'); res.status(500).json({ error: safeError(e) }); }
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
    await pool.query('UPDATE players SET game_data = $1, state_version = state_version + 1 WHERE wallet = $2', [JSON.stringify(gameData), wallet]);
    res.json({ success: true, data: pet });
  } catch (err) { logger.error('Upgrade pet error:', err); res.status(500).json({ success: false, message: '服务器错误' }); }
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
  } catch (err) { logger.error('Deploy pet error:', err); res.status(500).json({ success: false, message: '服务器错误' }); }
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
  } catch (err) { logger.error('Recall pet error:', err); res.status(500).json({ success: false, message: '服务器错误' }); }
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
    logger.error('Get pets error:', err);
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
    logger.error('Evolve pet error:', err);
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
    logger.error('Release pet error:', err);
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
    if (stones < l.buyout_price) { await client.query('ROLLBACK'); return res.status(400).json({ error: '焰晶不足' }); }

    // 退还之前的出价者
    if (l.current_bidder && l.current_bid > 0) {
      await client.query(
        `UPDATE players SET game_data = jsonb_set(game_data, '{spiritStones}', to_jsonb(GREATEST(0, (COALESCE(game_data->>'spiritStones','0'))::int + $1))),
         spirit_stones = spirit_stones + $1 WHERE wallet = $2`,
        [l.current_bid, l.current_bidder]
      );
    }

    // 扣除买家焰晶
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

    // 焰晶给卖家（扣5%手续费）
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
    res.json({ ok: true, message: `成功购买 ${l.item_name}，花费 ${l.buyout_price} 焰晶` });
  } catch (e) { await client.query('ROLLBACK'); res.status(500).json({ error: safeError(e) }); }
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
  } catch (e) { res.status(500).json({ error: safeError(e) }); }
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
  } catch (e) { res.status(500).json({ error: safeError(e) }); }
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
  } catch (e) { res.status(500).json({ error: safeError(e) }); }
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
  } catch (e) { res.status(500).json({ error: safeError(e) }); }
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
  } catch (e) { res.status(500).json({ error: safeError(e) }); }
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

    // 战斗模拟 - 使用实际属性
    const enemy = d.enemy_config;
    const bonuses = await getMountTitleBonuses(pool, w);
    const finalStats = computeFinalStats(gameData, bonuses);
    const playerAtk = Math.max(50, finalStats.attack || 50);
    const playerDef = Math.max(10, finalStats.defense || 10);
    const playerCritRate = finalStats.critRate || 0.05;
    const playerCritDmgBoost = finalStats.critDamageBoost || 0;
    const playerComboRate = finalStats.comboRate || 0;
    const playerDodgeRate = finalStats.dodgeRate || 0;
    const playerVampireRate = finalStats.vampireRate || 0;
    const playerFinalDmgBoost = finalStats.finalDamageBoost || 0;
    const playerFinalDmgReduce = finalStats.finalDamageReduce || 0;
    const playerCombatBoost = finalStats.combatBoost || 0;

    let playerHp = Math.max(500, finalStats.health || 500);
    const playerMaxHp = playerHp;
    let enemyHp = enemy.hp;
    const enemyMaxHp = enemy.hp;
    const combatLog = [];
    let round = 0;

    while (playerHp > 0 && enemyHp > 0 && round < 12) {
      round++;
      // 玩家攻击
      let pDmg = playerAtk * (100 / (100 + (enemy.defense || 10))) * (0.9 + Math.random() * 0.2);
      pDmg *= 1 + playerCombatBoost;
      pDmg *= 1 + playerFinalDmgBoost;
      const pCrit = Math.random() < playerCritRate;
      const pCombo = Math.random() < playerComboRate;
      if (pCrit) pDmg *= 1.5 + playerCritDmgBoost;
      if (pCombo) pDmg *= 1.3;
      const pFinalDmg = Math.max(1, Math.floor(pDmg));
      enemyHp = Math.max(0, enemyHp - pFinalDmg);
      // vampireRate lifesteal
      if (playerVampireRate > 0) {
        playerHp = Math.min(playerMaxHp, playerHp + Math.floor(pFinalDmg * playerVampireRate));
      }
      combatLog.push({
        round, actor: "player", damage: pFinalDmg, crit: pCrit, combo: pCombo,
        enemyHp: Math.max(0, enemyHp), enemyMaxHp, playerHp, playerMaxHp
      });
      if (enemyHp <= 0) break;

      // 敌人攻击
      let eDmg = enemy.attack * (100 / (100 + playerDef)) * (0.9 + Math.random() * 0.2);
      // player dodge
      const eDodged = Math.random() < playerDodgeRate;
      if (eDodged) {
        combatLog.push({
          round, actor: "enemy", damage: 0, dodged: true,
          enemyHp, enemyMaxHp, playerHp, playerMaxHp
        });
        continue;
      }
      const eCrit = Math.random() < 0.1;
      if (eCrit) eDmg *= 1.5;
      eDmg *= 1 - Math.min(0.7, playerFinalDmgReduce);
      const eFinalDmg = Math.max(1, Math.floor(eDmg));
      playerHp = Math.max(0, playerHp - eFinalDmg);
      combatLog.push({
        round, actor: "enemy", damage: eFinalDmg, crit: eCrit,
        enemyHp, enemyMaxHp, playerHp: Math.max(0, playerHp), playerMaxHp
      });
    }

    const result = playerHp > 0 && enemyHp <= 0 ? "victory" : "defeat";
    const victory = result === "victory";

    let rewards = {};
    if (victory) {
      const rc = d.rewards_config;
      rewards = { spiritStones: rc.spiritStones || 0, cultivation: rc.cultivation || 0 };
      if (rc.items) rewards.items = rc.items;
      if (rc.petEssence) rewards.petEssence = rc.petEssence;
      if (rc.refinementStones) rewards.refinementStones = rc.refinementStones;

      // buff检查
      const dBuf = gameData.buffs || {};
      if (dBuf.doubleCrystal && dBuf.doubleCrystal > Date.now()) {
        rewards.spiritStones = (rewards.spiritStones || 0) * 2;
        if (rc.spiritStones) rc.spiritStones *= 2;
      }
      // 发放焰晶、修为、焰兽精华、符文石
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
      [dungeon_id, w, p.name || "无名焰修", result, JSON.stringify(rewards), today]
    );

    const remaining = d.max_entries - used.rows[0].cnt - 1;
    res.json({ result, combatLog, rewards, remaining, dungeonName: d.name, enemy: d.enemy_config });
  } catch (e) { res.status(500).json({ error: safeError(e) }); }
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
  } catch (e) { res.status(500).json({ error: safeError(e) }); }
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
  } catch (e) { res.status(500).json({ error: safeError(e) }); }
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
  } catch (e) { res.status(500).json({ error: safeError(e) }); }
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

    // 白鹤免费，赤焰马10000焰晶，其他不可购买
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
      if (stones < cost) return res.status(400).json({ error: `焰晶不足，需要${cost}焰晶` });
      await pool.query(
        `UPDATE players SET spirit_stones = spirit_stones - $1,
         game_data = jsonb_set(game_data, '{spiritStones}', to_jsonb(GREATEST(0, (COALESCE((game_data->>'spiritStones')::bigint, 0) - $1)::bigint)))
         WHERE wallet = $2`,
        [cost, w]
      );
    }

    await pool.query('INSERT INTO player_mounts (wallet, mount_id) VALUES ($1, $2)', [w, mount_id]);
    res.json({ success: true, message: `成功获得坐骑: ${m.name}`, cost });
  } catch (e) { res.status(500).json({ error: safeError(e) }); }
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
  } catch (e) { res.status(500).json({ error: safeError(e) }); }
});

// POST /api/mount/deactivate - 取消激活
app.post('/api/mount/deactivate', auth, async (req, res) => {
  try {
    const w = req.user.wallet;
    await pool.query('UPDATE player_mounts SET is_active = false WHERE wallet = $1', [w]);
    res.json({ success: true });
  } catch (e) { res.status(500).json({ error: safeError(e) }); }
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
  } catch (e) { res.status(500).json({ error: safeError(e) }); }
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
  } catch (e) { res.status(500).json({ error: safeError(e) }); }
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
  } catch (e) { res.status(500).json({ error: safeError(e) }); }
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

    // 获取焰盟贡献
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
  } catch (e) { res.status(500).json({ error: safeError(e) }); }
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
  } catch (e) { res.status(500).json({ error: safeError(e) }); }
});

// POST /api/title/deactivate - 取消佩戴
app.post('/api/title/deactivate', auth, async (req, res) => {
  try {
    const w = req.user.wallet;
    await pool.query('UPDATE player_titles SET is_active = false WHERE wallet = $1', [w]);
    res.json({ success: true });
  } catch (e) { res.status(500).json({ error: safeError(e) }); }
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
  } catch (e) { res.status(500).json({ error: safeError(e) }); }
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

    // 保留10%焰晶
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
  } catch (e) { res.status(500).json({ error: safeError(e) }); }
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
  } catch (e) { res.status(500).json({ error: safeError(e) }); }
});

// GET /api/ascension/ranking - 飞升排行榜
app.get('/api/ascension/ranking', auth, async (req, res) => {
  try {
    const result = await pool.query(
      "SELECT p.wallet, p.name, p.level, COALESCE((p.game_data->>'ascensionCount')::int, 0) as ascension_count FROM players p WHERE COALESCE((p.game_data->>'ascensionCount')::int, 0) > 0 ORDER BY ascension_count DESC, p.level DESC LIMIT 50"
    );

    res.json({ ranking: result.rows.map((r, i) => ({ rank: i + 1, ...r })) });
  } catch (e) { res.status(500).json({ error: safeError(e) }); }
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
  } catch (e) { res.status(500).json({ error: safeError(e) }); }
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
  } catch (e) { res.status(500).json({ error: safeError(e) }); }
});
// ============ 背包扩容系统结束 ============

// ============ Admin 后台路由 ============
import registerAdminRoutes from './admin-routes.js';
import { registerDungeonRoutes } from './routes/dungeon.js';
await registerAdminRoutes(app, pool, auth, adminAuth);

// === 焚天塔副本系统 ===
registerDungeonRoutes(app, pool, auth);


// === 炼丹API ===
app.post('/api/alchemy/craft', auth, async (req, res) => {
  try {
    const { recipeId } = req.body;
    const w = req.user.wallet;
    const player = await pool.query('SELECT game_data FROM players WHERE wallet=$1', [w]);
    if (!player.rows.length) return res.status(404).json({ error: '玩家不存在' });
    const gd = typeof player.rows[0].game_data === 'string' ? JSON.parse(player.rows[0].game_data) : (player.rows[0].game_data || {});
    
    if (!gd.pillRecipes || !gd.pillRecipes.includes(recipeId)) {
      return res.json({ success: false, message: '未掌握该焰方' });
    }
    
    // 简单成功率（品阶越高越难）
    const gradeRates = { grade1:0.9, grade2:0.8, grade3:0.7, grade4:0.6, grade5:0.5, grade6:0.4, grade7:0.3, grade8:0.2 };
    // 需要前端传材料信息，这里简化：信任前端检查，后端只做扣材料+出丹
    const herbs = gd.herbs || [];
    
    // 从前端传来的配方材料列表
    const { materials, recipeName, recipeDesc, recipeGrade, effectType, effectValue, effectDuration } = req.body;
    if (!materials || !materials.length) return res.json({ success: false, message: '缺少材料信息' });
    
    // 检查并扣除材料
    for (const mat of materials) {
      let found = 0;
      for (let i = 0; i < mat.count; i++) {
        const idx = herbs.findIndex(h => (h.herbId || h.herb_id || h.id) === mat.herb);
        if (idx > -1) { herbs.splice(idx, 1); found++; }
      }
      if (found < mat.count) return res.json({ success: false, message: '材料不足: ' + mat.herb });
    }
    
    // 成功率判定
    const rate = gradeRates[recipeGrade] || 0.5;
    const luck = (gd.luck || 1) * (gd.alchemyRate || 1);
    if (Math.random() > rate * luck) {
      // 失败也扣材料
      gd.herbs = herbs;
      await pool.query('UPDATE players SET game_data=$1 WHERE wallet=$2', [JSON.stringify(gd), w]);
      return res.json({ success: false, message: '焰炼失败，材料已消耗' });
    }
    
    // 成功：扣材料 + 加丹药 + 消耗焰方
    gd.herbs = herbs;
    const pill = {
      id: recipeId + '_' + Date.now(),
      name: recipeName || recipeId,
      type: 'pill',
      description: recipeDesc || '',
      quality: 'common',
      effect: { type: effectType, value: effectValue, duration: effectDuration }
    };
    if (!gd.items) gd.items = [];
    gd.items.push(pill);
    
    // 消耗焰方
    const rIdx = gd.pillRecipes.indexOf(recipeId);
    if (rIdx > -1) gd.pillRecipes.splice(rIdx, 1);
    
    gd.pillsCrafted = (gd.pillsCrafted || 0) + 1;
    await pool.query('UPDATE players SET game_data=$1 WHERE wallet=$2', [JSON.stringify(gd), w]);
    res.json({ success: true, message: '焰炼成功！', pill, herbs: gd.herbs, pillRecipes: gd.pillRecipes, items: gd.items });
  } catch (e) { res.status(500).json({ error: safeError(e) }); }
});

// === 焰兽升级API ===
app.post('/api/pet/upgrade', auth, async (req, res) => {
  try {
    const { petId } = req.body;
    const w = req.user.wallet;
    const player = await pool.query('SELECT game_data FROM players WHERE wallet=$1', [w]);
    if (!player.rows.length) return res.status(404).json({ error: '玩家不存在' });
    const gd = typeof player.rows[0].game_data === 'string' ? JSON.parse(player.rows[0].game_data) : (player.rows[0].game_data || {});
    
    const items = gd.items || [];
    const petIdx = items.findIndex(i => String(i.id) === String(petId) && i.type === 'pet');
    if (petIdx === -1) return res.json({ success: false, message: '焰兽不存在' });
    
    const pet = items[petIdx];
    const cost = (pet.level || 1) * 10;
    const essence = gd.petEssence || 0;
    if (essence < cost) return res.json({ success: false, message: '焰兽精华不足' });
    
    gd.petEssence = essence - cost;
    pet.level = (pet.level || 1) + 1;
    
    const qm = { divine:2.0, celestial:1.8, mystic:1.6, spiritual:1.4, mortal:1.2 }[pet.rarity] || 1.2;
    if (pet.combatAttributes) {
      pet.combatAttributes.attack = Math.floor(pet.combatAttributes.attack * (1 + 0.01 * qm));
      pet.combatAttributes.health = Math.floor(pet.combatAttributes.health * (1 + 0.01 * qm));
      pet.combatAttributes.defense = Math.floor(pet.combatAttributes.defense * (1 + 0.01 * qm));
      pet.combatAttributes.speed = Math.floor(pet.combatAttributes.speed * (1 + 0.01 * qm));
    }
    
    items[petIdx] = pet;
    gd.items = items;
    
    // 如果是出战焰兽也更新
    if (gd.activePet && String(gd.activePet.id) === String(petId)) {
      gd.activePet = pet;
    }
    
    await pool.query('UPDATE players SET game_data=$1 WHERE wallet=$2', [JSON.stringify(gd), w]);
    res.json({ success: true, message: '升级成功！等级: ' + pet.level, pet, petEssence: gd.petEssence });
  } catch (e) { res.status(500).json({ error: safeError(e) }); }
});

// === 服用丹药API ===
app.post('/api/pill/use', auth, async (req, res) => {
  try {
    const { pillId } = req.body;
    const w = req.user.wallet;
    const player = await pool.query('SELECT game_data FROM players WHERE wallet=$1', [w]);
    if (!player.rows.length) return res.status(404).json({ error: '玩家不存在' });
    const gd = typeof player.rows[0].game_data === 'string' ? JSON.parse(player.rows[0].game_data) : (player.rows[0].game_data || {});
    
    const items = gd.items || [];
    const pillIdx = items.findIndex(i => String(i.id) === String(pillId) && i.type === 'pill');
    if (pillIdx === -1) return res.json({ success: false, message: '丹药不存在' });
    
    const pill = items[pillIdx];
    const now = Date.now();
    
    // 检查是否已有相同效果的buff
    if (!gd.activeEffects) gd.activeEffects = [];
    gd.activeEffects = gd.activeEffects.filter(e => e.endTime > now);
    const existing = gd.activeEffects.find(e => e.type === pill.effect.type);
    if (existing) {
      return res.json({ success: false, message: '已有相同效果的丹药在生效中，不能叠加' });
    }
    
    // 添加效果
    gd.activeEffects.push({
      ...pill.effect,
      startTime: now,
      endTime: now + (pill.effect.duration || 3600) * 1000
    });
    
    // 移除丹药
    items.splice(pillIdx, 1);
    gd.items = items;
    gd.pillsConsumed = (gd.pillsConsumed || 0) + 1;
    
    await pool.query('UPDATE players SET game_data=$1 WHERE wallet=$2', [JSON.stringify(gd), w]);
    res.json({ success: true, message: '服用成功！', activeEffects: gd.activeEffects, items: gd.items });
  } catch (e) { res.status(500).json({ error: safeError(e) }); }
});

// === 焰兽升星API ===
app.post('/api/pet/evolve', auth, async (req, res) => {
  try {
    const { petId, foodPetId } = req.body;
    const w = req.user.wallet;
    const r = await pool.query('SELECT game_data FROM players WHERE wallet=$1', [w]);
    if (!r.rows.length) return res.status(404).json({ error: '玩家不存在' });
    const gd = typeof r.rows[0].game_data === 'string' ? JSON.parse(r.rows[0].game_data) : (r.rows[0].game_data || {});
    const items = gd.items || [];
    const petIdx = items.findIndex(i => String(i.id) === String(petId) && i.type === 'pet');
    const foodIdx = items.findIndex(i => String(i.id) === String(foodPetId) && i.type === 'pet');
    if (petIdx === -1) return res.json({ success: false, message: '焰兽不存在' });
    if (foodIdx === -1) return res.json({ success: false, message: '材料焰兽不存在' });
    if (petIdx === foodIdx) return res.json({ success: false, message: '不能用自己升星' });
    const pet = items[petIdx]; const food = items[foodIdx];
    if (pet.rarity !== food.rarity || pet.name !== food.name) return res.json({ success: false, message: '只能使用相同品质和名字的焰兽升星' });
    if ((pet.star || 0) >= 10) return res.json({ success: false, message: '已达最高星级' });
    pet.star = (pet.star || 0) + 1;
    const starBonus = 1 + pet.star * 0.05;
    if (pet.combatAttributes) {
      pet.combatAttributes.attack = Math.floor(pet.combatAttributes.attack * starBonus / (starBonus - 0.05));
      pet.combatAttributes.health = Math.floor(pet.combatAttributes.health * starBonus / (starBonus - 0.05));
      pet.combatAttributes.defense = Math.floor(pet.combatAttributes.defense * starBonus / (starBonus - 0.05));
      pet.combatAttributes.speed = Math.floor(pet.combatAttributes.speed * starBonus / (starBonus - 0.05));
    }
    items.splice(foodIdx, 1);
    gd.items = items;
    if (gd.activePet && String(gd.activePet.id) === String(petId)) gd.activePet = pet;
    await pool.query('UPDATE players SET game_data=$1 WHERE wallet=$2', [JSON.stringify(gd), w]);
    res.json({ success: true, message: '升星成功！当前' + pet.star + '星', pet, items: gd.items });
  } catch (e) { res.status(500).json({ error: safeError(e) }); }
});

// === 焰兽放生API ===
app.post('/api/pet/release', auth, async (req, res) => {
  try {
    const { petId } = req.body;
    const w = req.user.wallet;
    const r = await pool.query('SELECT game_data FROM players WHERE wallet=$1', [w]);
    if (!r.rows.length) return res.status(404).json({ error: '玩家不存在' });
    const gd = typeof r.rows[0].game_data === 'string' ? JSON.parse(r.rows[0].game_data) : (r.rows[0].game_data || {});
    const items = gd.items || [];
    const idx = items.findIndex(i => String(i.id) === String(petId) && i.type === 'pet');
    if (idx === -1) return res.json({ success: false, message: '焰兽不存在' });
    if (gd.activePet && String(gd.activePet.id) === String(petId)) gd.activePet = null;
    const essenceGain = { divine:50, celestial:30, mystic:20, spiritual:10, mortal:5 }[items[idx].rarity] || 5;
    gd.petEssence = (gd.petEssence || 0) + essenceGain;
    items.splice(idx, 1);
    gd.items = items;
    await pool.query('UPDATE players SET game_data=$1 WHERE wallet=$2', [JSON.stringify(gd), w]);
    res.json({ success: true, message: '放生成功，获得' + essenceGain + '精华', items: gd.items, petEssence: gd.petEssence, activePet: gd.activePet });
  } catch (e) { res.status(500).json({ error: safeError(e) }); }
});

// === 焰兽批量放生API ===
app.post('/api/pet/release-batch', auth, async (req, res) => {
  try {
    const { rarity } = req.body; // 'all' or specific rarity
    const w = req.user.wallet;
    const r = await pool.query('SELECT game_data FROM players WHERE wallet=$1', [w]);
    if (!r.rows.length) return res.status(404).json({ error: '玩家不存在' });
    const gd = typeof r.rows[0].game_data === 'string' ? JSON.parse(r.rows[0].game_data) : (r.rows[0].game_data || {});
    const items = gd.items || [];
    const activeId = gd.activePet ? String(gd.activePet.id) : null;
    let count = 0; let essenceTotal = 0;
    const essenceMap = { divine:50, celestial:30, mystic:20, spiritual:10, mortal:5 };
    gd.items = items.filter(i => {
      if (i.type !== 'pet') return true;
      if (String(i.id) === activeId) return true;
      if (rarity !== 'all' && i.rarity !== rarity) return true;
      count++; essenceTotal += essenceMap[i.rarity] || 5;
      return false;
    });
    gd.petEssence = (gd.petEssence || 0) + essenceTotal;
    await pool.query('UPDATE players SET game_data=$1 WHERE wallet=$2', [JSON.stringify(gd), w]);
    res.json({ success: true, message: '放生' + count + '只，获得' + essenceTotal + '精华', count, items: gd.items, petEssence: gd.petEssence });
  } catch (e) { res.status(500).json({ error: safeError(e) }); }
});

// === 焰兽出战/召回API ===
app.post('/api/pet/deploy', auth, async (req, res) => {
  try {
    const { petId } = req.body; // null = recall
    const w = req.user.wallet;
    const r = await pool.query('SELECT game_data FROM players WHERE wallet=$1', [w]);
    if (!r.rows.length) return res.status(404).json({ error: '玩家不存在' });
    const gd = typeof r.rows[0].game_data === 'string' ? JSON.parse(r.rows[0].game_data) : (r.rows[0].game_data || {});
    if (!petId) {
      gd.activePet = null;
      await pool.query('UPDATE players SET game_data=$1 WHERE wallet=$2', [JSON.stringify(gd), w]);
      return res.json({ success: true, message: '已召回焰兽', activePet: null });
    }
    const pet = (gd.items || []).find(i => String(i.id) === String(petId) && i.type === 'pet');
    if (!pet) return res.json({ success: false, message: '焰兽不存在' });
    gd.activePet = pet;
    await pool.query('UPDATE players SET game_data=$1 WHERE wallet=$2', [JSON.stringify(gd), w]);
    res.json({ success: true, message: '出战成功', activePet: pet });
  } catch (e) { res.status(500).json({ error: safeError(e) }); }
});


// === M4: Equipment dual-write helper ===
async function syncEquipToNewTables(client, playerId, slot, equipItem, action) {
  // action: 'wear' or 'unwear'
  try {
    if (action === 'wear' && equipItem) {
      const origId = String(equipItem.id);
      // Find or create in inventory_items
      let invRow = await client.query('SELECT id FROM inventory_items WHERE player_id=$1 AND original_id=$2', [playerId, origId]);
      if (!invRow.rows.length) {
        invRow = await client.query(
          `INSERT INTO inventory_items (player_id, original_id, name, type, quality, stats, attributes, enhance_level, source)
           VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9) RETURNING id`,
          [playerId, origId, equipItem.name || '未知', equipItem.type || slot, equipItem.quality || 'common',
           JSON.stringify(equipItem.stats || {}), JSON.stringify(equipItem.attributes || {}),
           equipItem.enhanceLevel || 0, 'game']
        );
      }
      const itemId = invRow.rows[0].id;
      await client.query(
        `INSERT INTO equip_slots (player_id, slot, item_id) VALUES ($1, $2, $3)
         ON CONFLICT (player_id, slot) DO UPDATE SET item_id = $3, updated_at = now()`,
        [playerId, slot, itemId]
      );
    } else if (action === 'unwear') {
      await client.query(
        `DELETE FROM equip_slots WHERE player_id=$1 AND slot=$2`,
        [playerId, slot]
      );
    }
  } catch(e) {
    logger.error('[M4 DualWrite]', action, 'sync failed:', e.message);
    // Non-fatal: game_data is still the source of truth during transition
  }
}

// === 装备穿戴API ===
app.post('/api/equip/wear', auth, idempotent(pool, 'wear'), async (req, res) => {
  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    const { equipId, slot } = req.body;
    const w = req.user.wallet;
    const r = await client.query('SELECT game_data, state_version FROM players WHERE wallet=$1 FOR UPDATE', [w]);
    if (!r.rows.length) { await client.query('ROLLBACK'); return res.status(404).json({ error: '玩家不存在' }); }
    const gd = typeof r.rows[0].game_data === 'string' ? JSON.parse(r.rows[0].game_data) : (r.rows[0].game_data || {});
    const items = gd.items || [];
    const idx = items.findIndex(i => String(i.id) === String(equipId));
    if (idx === -1) { await client.query('ROLLBACK'); return res.json({ success: false, message: '装备不存在' }); }
    const equip = items[idx];
    if (!gd.equippedArtifacts) gd.equippedArtifacts = {};
    const targetSlot = slot || equip.type;
    if (gd.equippedArtifacts[targetSlot]) {
      items.push(gd.equippedArtifacts[targetSlot]);
    }
    gd.equippedArtifacts[targetSlot] = equip;
    items.splice(idx, 1);
    gd.items = items;
    recalcDerivedStats(gd);
    const newVersion = (Number(r.rows[0].state_version) || 0) + 1;
    await client.query('UPDATE players SET game_data=$1, state_version=$2 WHERE wallet=$3', [JSON.stringify(gd), newVersion, w]);
    // M4: dual-write to new tables
    const _playerId = (await client.query('SELECT id FROM players WHERE wallet=$1', [w])).rows[0]?.id;
    if (_playerId) await syncEquipToNewTables(client, _playerId, targetSlot, equip, 'wear');
    await client.query('COMMIT');
    res.json({ success: true, message: '装备成功', items: gd.items, equippedArtifacts: gd.equippedArtifacts, state_version: newVersion, computed_at: new Date().toISOString() });
  } catch (e) {
    await client.query('ROLLBACK').catch(() => {});
    res.status(500).json({ error: e.message || '服务器错误' });
  } finally {
    client.release();
  }
});

// === 装备卸下API ===
app.post('/api/equip/unwear', auth, idempotent(pool, 'unwear'), async (req, res) => {
  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    const { slot } = req.body;
    const w = req.user.wallet;
    const r = await client.query('SELECT game_data, state_version FROM players WHERE wallet=$1 FOR UPDATE', [w]);
    if (!r.rows.length) { await client.query('ROLLBACK'); return res.status(404).json({ error: '玩家不存在' }); }
    const gd = typeof r.rows[0].game_data === 'string' ? JSON.parse(r.rows[0].game_data) : (r.rows[0].game_data || {});
    if (!gd.equippedArtifacts || !gd.equippedArtifacts[slot]) { await client.query('ROLLBACK'); return res.json({ success: false, message: '该槽位没有装备' }); }
    if (!gd.items) gd.items = [];
    gd.items.push(gd.equippedArtifacts[slot]);
    gd.equippedArtifacts[slot] = null;
    recalcDerivedStats(gd);
    const newVersion = (Number(r.rows[0].state_version) || 0) + 1;
    await client.query('UPDATE players SET game_data=$1, state_version=$2 WHERE wallet=$3', [JSON.stringify(gd), newVersion, w]);
    // M4: dual-write to new tables
    const _playerId2 = (await client.query('SELECT id FROM players WHERE wallet=$1', [w])).rows[0]?.id;
    if (_playerId2) await syncEquipToNewTables(client, _playerId2, slot, null, 'unwear');
    await client.query('COMMIT');
    res.json({ success: true, message: '卸下成功', items: gd.items, equippedArtifacts: gd.equippedArtifacts, state_version: newVersion, computed_at: new Date().toISOString() });
  } catch (e) {
    await client.query('ROLLBACK').catch(() => {});
    res.status(500).json({ error: e.message || '服务器错误' });
  } finally {
    client.release();
  }
});

// === 装备强化API ===
app.post('/api/equip/enhance', auth, idempotent(pool, 'enhance'), async (req, res) => {
  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    const { equipId, slot } = req.body;
    const w = req.user.wallet;
    const r = await client.query('SELECT game_data, state_version FROM players WHERE wallet=$1 FOR UPDATE', [w]);
    if (!r.rows.length) { await client.query('ROLLBACK'); return res.status(404).json({ error: '玩家不存在' }); }
    const gd = typeof r.rows[0].game_data === 'string' ? JSON.parse(r.rows[0].game_data) : (r.rows[0].game_data || {});
    const stones = gd.reinforceStones || 0;
    const cost = 1;
    if (stones < cost) { await client.query('ROLLBACK'); return res.json({ success: false, message: '强化石不足' }); }
    let equip = null; let inSlot = null;
    if (slot && gd.equippedArtifacts && gd.equippedArtifacts[slot] && String(gd.equippedArtifacts[slot].id) === String(equipId)) {
      equip = gd.equippedArtifacts[slot]; inSlot = slot;
    } else {
      const idx = (gd.items || []).findIndex(i => String(i.id) === String(equipId));
      if (idx > -1) equip = gd.items[idx];
    }
    if (!equip) { await client.query('ROLLBACK'); return res.json({ success: false, message: '装备不存在' }); }
    const level = (equip.enhanceLevel || 0);
    const maxLevel = 20;
    if (level >= maxLevel) { await client.query('ROLLBACK'); return res.json({ success: false, message: '已达最高强化等级' }); }
    const rate = Math.max(0.3, 1 - level * 0.05);
    gd.reinforceStones = stones - cost;
    const newVersion = (Number(r.rows[0].state_version) || 0) + 1;
    if (Math.random() < rate) {
      equip.enhanceLevel = level + 1;
      const bonus = 1 + equip.enhanceLevel * 0.05;
      if (equip.attributes) {
        for (const k of Object.keys(equip.attributes)) {
          if (typeof equip.attributes[k] === 'number') equip.attributes[k] = Math.floor(equip.attributes[k] * (1 + 0.05) );
        }
      }
      if (inSlot) gd.equippedArtifacts[inSlot] = equip;
      recalcDerivedStats(gd);
      await client.query('UPDATE players SET game_data=$1, state_version=$2 WHERE wallet=$3', [JSON.stringify(gd), newVersion, w]);
      await client.query('COMMIT');
      // M4: sync enhanced stats to inventory_items
      try { const _origId = String(equipId); const _pid3 = (await client.query("SELECT id FROM players WHERE wallet=", [w])).rows[0]?.id; if (_pid3) await client.query("UPDATE inventory_items SET stats=, attributes=, enhance_level= WHERE player_id= AND original_id=", [JSON.stringify(equip.stats || {}), JSON.stringify(equip.attributes || {}), equip.enhanceLevel || 0, _pid3, _origId]); } catch(e) { logger.error("[M4] enhance sync:", e.message); }
      res.json({ success: true, message: '强化成功！+' + equip.enhanceLevel, equip, reinforceStones: gd.reinforceStones, items: gd.items, equippedArtifacts: gd.equippedArtifacts, state_version: newVersion, computed_at: new Date().toISOString() });
    } else {
      recalcDerivedStats(gd);
      await client.query('UPDATE players SET game_data=$1, state_version=$2 WHERE wallet=$3', [JSON.stringify(gd), newVersion, w]);
      await client.query('COMMIT');
      res.json({ success: false, message: '强化失败，强化石已消耗', reinforceStones: gd.reinforceStones, state_version: newVersion, computed_at: new Date().toISOString() });
    }
  } catch (e) {
    await client.query('ROLLBACK').catch(() => {});
    res.status(500).json({ error: e.message || '服务器错误' });
  } finally {
    client.release();
  }
});

// === 装备分解API ===
app.post('/api/equip/disassemble', auth, async (req, res) => {
  try {
    const { equipId } = req.body;
    const w = req.user.wallet;
    const r = await pool.query('SELECT game_data FROM players WHERE wallet=$1', [w]);
    if (!r.rows.length) return res.status(404).json({ error: '玩家不存在' });
    const gd = typeof r.rows[0].game_data === 'string' ? JSON.parse(r.rows[0].game_data) : (r.rows[0].game_data || {});
    const items = gd.items || [];
    const idx = items.findIndex(i => String(i.id) === String(equipId));
    if (idx === -1) return res.json({ success: false, message: '装备不存在' });
    const equip = items[idx];
    const stoneGain = { legendary:5, epic:3, rare:2, uncommon:1, common:1 }[equip.quality] || 1;
    const stoneGainTotal = stoneGain + (equip.enhanceLevel || 0);
    gd.reinforceStones = (gd.reinforceStones || 0) + stoneGainTotal;
    items.splice(idx, 1);
    gd.items = items;
    await pool.query('UPDATE players SET game_data=$1 WHERE wallet=$2', [JSON.stringify(gd), w]);
    res.json({ success: true, message: '分解成功，获得' + stoneGainTotal + '强化石', reinforceStones: gd.reinforceStones, items: gd.items });
  } catch (e) { res.status(500).json({ error: safeError(e) }); }
});

// === 新手礼包（防重复领取）===
app.post('/api/gift/newplayer', auth, async (req, res) => {
  try {
    const wallet = req.user.wallet;
    const r = await pool.query('SELECT game_data FROM players WHERE wallet = $1', [wallet]);
    if (!r.rows.length) return res.status(404).json({ error: '玩家不存在' });
    const gd = typeof r.rows[0].game_data === 'string' ? JSON.parse(r.rows[0].game_data) : (r.rows[0].game_data || {});
    if (gd.newPlayerGiftClaimed) return res.status(400).json({ error: '新手礼包已领取' });
    gd.spiritStones = (gd.spiritStones || 0) + 20000;
    gd.newPlayerGiftClaimed = true;
    gd.isNewPlayer = false;
    await pool.query('UPDATE players SET game_data = $1, spirit_stones = $2 WHERE wallet = $3',
      [JSON.stringify(gd), gd.spiritStones, wallet]);
    res.json({ success: true, spiritStones: gd.spiritStones });
  } catch (e) { res.status(500).json({ error: safeError(e) }); }
});
// === 玩家资料 ===
app.get("/api/player/profile", auth, async (req, res) => {
  try {
    const r = await pool.query("SELECT name, level, realm, vip_level, combat_power, created_at, total_recharge FROM players WHERE wallet = $1", [req.wallet]);
    if (r.rows.length === 0) return res.status(404).json({ error: "玩家不存在" });
    const p = r.rows[0];
    res.json({ success: true, name: p.name, level: p.level, realm: p.realm, vipLevel: p.vip_level, combatPower: p.combat_power, createdAt: p.created_at, totalRecharge: p.total_recharge });
  } catch (e) { res.status(500).json({ error: safeError(e) }); }
});


// === 改名（服务端扣费）===
app.post('/api/player/rename', auth, async (req, res) => {
  try {
    const { newName } = req.body;
    const wallet = req.user.wallet;
    if (!newName || newName.length < 1 || newName.length > 12) return res.status(400).json({ error: '名字长度1-12字' });
    const r = await pool.query('SELECT game_data FROM players WHERE wallet = $1', [wallet]);
    if (!r.rows.length) return res.status(404).json({ error: '玩家不存在' });
    const gd = typeof r.rows[0].game_data === 'string' ? JSON.parse(r.rows[0].game_data) : (r.rows[0].game_data || {});
    const count = gd.nameChangeCount || 0;
    const cost = count === 0 ? 0 : Math.pow(2, count) * 100;
    if ((gd.spiritStones || 0) < cost) return res.status(400).json({ error: '焰晶不足，需要' + cost });
    gd.spiritStones = (gd.spiritStones || 0) - cost;
    gd.name = newName;
    gd.nameChangeCount = count + 1;
    await pool.query('UPDATE players SET game_data = $1, spirit_stones = $2, name = $3 WHERE wallet = $4',
      [JSON.stringify(gd), gd.spiritStones, newName, wallet]);
    res.json({ success: true, spiritStones: gd.spiritStones, nameChangeCount: gd.nameChangeCount });
  } catch (e) { res.status(500).json({ error: safeError(e) }); }
});


// ============ 装备淬火(enhance) 服务端验证 ============
app.post('/api/equipment/enhance', auth, async (req, res) => {
  try {
    const wallet = req.user.wallet;
    const { equipmentId } = req.body;
    if (!equipmentId) return res.status(400).json({ error: '缺少装备ID' });
    const r = await pool.query('SELECT game_data FROM players WHERE wallet = $1', [wallet]);
    if (!r.rows.length) return res.status(404).json({ error: '玩家不存在' });
    const gd = r.rows[0].game_data;
    // 在已装备和背包中查找装备
    let equip = null, location = null, slotKey = null;
    const ea = gd.equippedArtifacts || {};
    for (const [slot, item] of Object.entries(ea)) {
      if (item && String(item.id) === String(equipmentId)) { equip = item; location = 'equipped'; slotKey = slot; break; }
    }
    if (!equip) {
      const idx = (gd.items || []).findIndex(i => String(i.id) === String(equipmentId));
      if (idx >= 0) { equip = gd.items[idx]; location = 'items'; slotKey = idx; }
    }
    if (!equip) return res.status(404).json({ error: '装备不存在' });
    const currentLevel = equip.enhanceLevel || 0;
    if (currentLevel >= 100) return res.status(400).json({ error: '已达最大淬火等级' });
    const cost = 10 * (currentLevel + 1);
    const stones = gd.reinforceStones || 0;
    if (stones < cost) return res.status(400).json({ error: '淬火石不足', need: cost, have: stones });
    // 成功率
    const successRate = 1.0 - currentLevel * 0.05;
    const isSuccess = Math.random() < successRate;
    gd.reinforceStones = stones - cost;
    if (isSuccess && equip.stats) {
      const oldStats = { ...equip.stats };
      const pctStats = ['critRate','critDamageBoost','dodgeRate','vampireRate','finalDamageBoost','finalDamageReduce'];
      for (const key of Object.keys(equip.stats)) {
        if (typeof equip.stats[key] === 'number') {
          equip.stats[key] *= 1.1;
          equip.stats[key] = pctStats.includes(key) ? Math.round(equip.stats[key] * 100) / 100 : Math.round(equip.stats[key]);
        }
      }
      equip.enhanceLevel = currentLevel + 1;
      if (location === 'equipped') gd.equippedArtifacts[slotKey] = equip;
      else gd.items[slotKey] = equip;
      await pool.query('UPDATE players SET game_data = $1 WHERE wallet = $2', [JSON.stringify(gd), wallet]);
      res.json({ success: true, enhanced: true, cost, newLevel: equip.enhanceLevel, newStats: equip.stats, oldStats, reinforceStones: gd.reinforceStones });
    } else {
      await pool.query('UPDATE players SET game_data = $1 WHERE wallet = $2', [JSON.stringify(gd), wallet]);
      res.json({ success: true, enhanced: false, cost, message: '淬火失败', reinforceStones: gd.reinforceStones });
    }
  } catch (e) { logger.error('enhance error:', e); res.status(500).json({ error: safeError(e) }); }
});



// ============ 装备铭符(reforge) 服务端验证 ============
app.post('/api/equipment/reforge', auth, async (req, res) => {
  try {
    const wallet = req.user.wallet;
    const { equipmentId } = req.body;
    if (!equipmentId) return res.status(400).json({ error: '缺少装备ID' });
    const r = await pool.query('SELECT game_data FROM players WHERE wallet = $1', [wallet]);
    if (!r.rows.length) return res.status(404).json({ error: '玩家不存在' });
    const gd = r.rows[0].game_data;
    let equip = null, location = null, slotKey = null;
    const ea = gd.equippedArtifacts || {};
    for (const [slot, item] of Object.entries(ea)) {
      if (item && String(item.id) === String(equipmentId)) { equip = item; location = 'equipped'; slotKey = slot; break; }
    }
    if (!equip) {
      const idx = (gd.items || []).findIndex(i => String(i.id) === String(equipmentId));
      if (idx >= 0) { equip = gd.items[idx]; location = 'items'; slotKey = idx; }
    }
    if (!equip || !equip.stats || !equip.type) return res.status(404).json({ error: '装备不存在或无效' });
    const cost = 10;
    const stones = gd.refinementStones || 0;
    if (stones < cost) return res.status(400).json({ error: '符文石不足', need: cost, have: stones });
    const reforgeableStats = {
      weapon: ['attack','critRate','critDamageBoost'], head: ['defense','health','stunResist'],
      body: ['defense','health','finalDamageReduce'], legs: ['defense','speed','dodgeRate'],
      feet: ['defense','speed','dodgeRate'], shoulder: ['defense','health','counterRate'],
      hands: ['attack','critRate','comboRate'], wrist: ['defense','counterRate','vampireRate'],
      necklace: ['health','healBoost','spiritRate'], ring1: ['attack','critDamageBoost','finalDamageBoost'],
      ring2: ['defense','critDamageReduce','resistanceBoost'], belt: ['health','defense','combatBoost'],
      artifact: ['attack','critRate','comboRate']
    };
    const availableStats = reforgeableStats[equip.type] || [];
    const oldStats = { ...equip.stats };
    const tempStats = { ...equip.stats };
    const originKeys = Object.keys(tempStats);
    const pctStats = ['critRate','critDamageBoost','dodgeRate','vampireRate','finalDamageBoost','finalDamageReduce'];
    const modCount = Math.floor(Math.random() * 3) + 1;
    const indices = [...new Set(Array.from({length: modCount}, () => Math.floor(Math.random() * originKeys.length)))].slice(0, 3);
    indices.forEach(idx => {
      const origKey = originKeys[idx];
      let curKey = origKey;
      const baseVal = tempStats[origKey];
      if (Math.random() < 0.3) {
        const avail = availableStats.filter(s => !originKeys.includes(s) && s !== origKey);
        if (avail.length > 0) { const nk = avail[Math.floor(Math.random() * avail.length)]; delete tempStats[origKey]; curKey = nk; }
      }
      const delta = Math.random() * 0.6 - 0.3;
      let nv = baseVal * (1 + delta);
      if (pctStats.includes(curKey)) { tempStats[curKey] = Math.min(Math.max(Number(nv.toFixed(2)), baseVal * 0.7), baseVal * 1.3); }
      else { tempStats[curKey] = Math.min(Math.max(Math.round(nv), Math.round(baseVal * 0.7)), Math.round(baseVal * 1.3)); }
    });
    if (Object.keys(tempStats).length !== originKeys.length) return res.status(500).json({ error: '铭符异常' });
    gd.refinementStones = stones - cost;
    gd._pendingReforge = { equipmentId: String(equipmentId), location, slotKey, newStats: tempStats, oldStats };
    await pool.query('UPDATE players SET game_data = $1 WHERE wallet = $2', [JSON.stringify(gd), wallet]);
    res.json({ success: true, cost, oldStats, newStats: tempStats, refinementStones: gd.refinementStones });
  } catch (e) { logger.error('reforge error:', e); res.status(500).json({ error: safeError(e) }); }
});

// ============ 铭符确认/取消 ============
app.post('/api/equipment/reforge-confirm', auth, async (req, res) => {
  try {
    const wallet = req.user.wallet;
    const { confirm } = req.body;
    const r = await pool.query('SELECT game_data FROM players WHERE wallet = $1', [wallet]);
    if (!r.rows.length) return res.status(404).json({ error: '玩家不存在' });
    const gd = r.rows[0].game_data;
    const pending = gd._pendingReforge;
    if (!pending) return res.status(400).json({ error: '没有待确认的铭符' });
    if (confirm) {
      let equip = null;
      if (pending.location === 'equipped') { equip = (gd.equippedArtifacts || {})[pending.slotKey]; }
      else { equip = (gd.items || [])[pending.slotKey]; }
      if (equip && String(equip.id) === pending.equipmentId) {
        equip.stats = pending.newStats;
        if (pending.location === 'equipped') gd.equippedArtifacts[pending.slotKey] = equip;
        else gd.items[pending.slotKey] = equip;
      }
    }
    delete gd._pendingReforge;
    await pool.query('UPDATE players SET game_data = $1 WHERE wallet = $2', [JSON.stringify(gd), wallet]);
    res.json({ success: true, confirmed: !!confirm });
  } catch (e) { logger.error('reforge-confirm error:', e); res.status(500).json({ error: safeError(e) }); }
});



// ============ 卖装备 服务端验证 ============
const qualityStoneMap = { mythic: 6, legendary: 5, epic: 4, rare: 3, uncommon: 2, common: 1 };

app.post('/api/equipment/sell', auth, async (req, res) => {
  try {
    const wallet = req.user.wallet;
    const { equipmentId } = req.body;
    if (!equipmentId) return res.status(400).json({ error: '缺少装备ID' });
    const r = await pool.query('SELECT game_data FROM players WHERE wallet = $1', [wallet]);
    if (!r.rows.length) return res.status(404).json({ error: '玩家不存在' });
    const gd = r.rows[0].game_data;
    const items = gd.items || [];
    const idx = items.findIndex(i => String(i.id) === String(equipmentId));
    if (idx < 0) return res.status(404).json({ error: '装备不存在' });
    const equip = items[idx];
    // 不能卖已装备的
    const ea = gd.equippedArtifacts || {};
    for (const [, item] of Object.entries(ea)) {
      if (item && String(item.id) === String(equipmentId)) return res.status(400).json({ error: '请先卸下装备' });
    }
    // 不能卖丹药/宠物
    if (equip.type === 'pill' || equip.type === 'pet') return res.status(400).json({ error: '该物品不能出售' });
    const stones = qualityStoneMap[equip.quality] || 1;
    gd.items.splice(idx, 1);
    gd.reinforceStones = (gd.reinforceStones || 0) + stones;
    await pool.query('UPDATE players SET game_data = $1 WHERE wallet = $2', [JSON.stringify(gd), wallet]);
    res.json({ success: true, stones, reinforceStones: gd.reinforceStones, itemCount: gd.items.length });
  } catch (e) { logger.error('sell error:', e); res.status(500).json({ error: safeError(e) }); }
});

app.post('/api/equipment/batch-sell', auth, async (req, res) => {
  try {
    const wallet = req.user.wallet;
    const { quality, equipmentType } = req.body;
    const r = await pool.query('SELECT game_data FROM players WHERE wallet = $1', [wallet]);
    if (!r.rows.length) return res.status(404).json({ error: '玩家不存在' });
    const gd = r.rows[0].game_data;
    const equippedIds = new Set();
    for (const [, item] of Object.entries(gd.equippedArtifacts || {})) {
      if (item) equippedIds.add(String(item.id));
    }
    let totalStones = 0, count = 0;
    gd.items = (gd.items || []).filter(item => {
      if (!item || !item.type || item.type === 'pill' || item.type === 'pet') return true;
      if (equippedIds.has(String(item.id))) return true;
      if (quality && item.quality !== quality) return true;
      if (equipmentType && item.type !== equipmentType) return true;
      const s = qualityStoneMap[item.quality] || 1;
      totalStones += s; count++;
      return false;
    });
    gd.reinforceStones = (gd.reinforceStones || 0) + totalStones;
    await pool.query('UPDATE players SET game_data = $1 WHERE wallet = $2', [JSON.stringify(gd), wallet]);
    res.json({ success: true, totalStones, count, reinforceStones: gd.reinforceStones, itemCount: gd.items.length });
  } catch (e) { logger.error('batch-sell error:', e); res.status(500).json({ error: safeError(e) }); }
});



// === 玩家活跃度统计（管理员） ===
app.get('/api/admin/activity', auth, async (req, res) => {
  try {
    if (!ADMIN_WALLETS.includes(req.user.wallet.toLowerCase()))
      return res.status(403).json({ error: '无权限' });
    const [dau, wau, mau, newToday, loginToday] = await Promise.all([
      pool.query("SELECT COUNT(DISTINCT wallet) as c FROM players WHERE updated_at > NOW() - INTERVAL '1 day'"),
      pool.query("SELECT COUNT(DISTINCT wallet) as c FROM players WHERE updated_at > NOW() - INTERVAL '7 days'"),
      pool.query("SELECT COUNT(DISTINCT wallet) as c FROM players WHERE updated_at > NOW() - INTERVAL '30 days'"),
      pool.query("SELECT COUNT(*) as c FROM players WHERE created_at::date = CURRENT_DATE"),
      pool.query("SELECT COUNT(DISTINCT wallet) as c FROM login_logs WHERE created_at::date = CURRENT_DATE")
    ]);
    // 最近7天每日登录趋势
    const trend = await pool.query(
      "SELECT created_at::date as day, COUNT(DISTINCT wallet) as logins FROM login_logs WHERE created_at > NOW() - INTERVAL '7 days' GROUP BY day ORDER BY day"
    );
    res.json({
      dau: +dau.rows[0].c, wau: +wau.rows[0].c, mau: +mau.rows[0].c,
      newToday: +newToday.rows[0].c, loginToday: +loginToday.rows[0].c,
      trend: trend.rows
    });
  } catch (e) { res.status(500).json({ error: safeError(e) }); }
});

// === 装备分解回收 ===
app.post('/api/equipment/disassemble', auth, async (req, res) => {
  try {
    const { equipmentId } = req.body;
    if (!equipmentId) return res.status(400).json({ error: '缺少装备ID' });
    const result = await pool.query('SELECT game_data FROM players WHERE wallet=$1', [req.user.wallet]);
    const gd = result.rows[0]?.game_data;
    if (!gd) return res.status(404).json({ error: '玩家不存在' });
    const items = gd.items || [];
    const idx = items.findIndex(i => String(i.id) === String(equipmentId) && i.type !== 'pill' && i.type !== 'pet');
    if (idx === -1) return res.status(400).json({ error: '装备不存在' });
    const equip = items[idx];
    // 根据品质计算回收材料
    const qualityRewards = {
      common: { stones: 50, reinforce: 1 },
      uncommon: { stones: 150, reinforce: 3 },
      rare: { stones: 500, reinforce: 8 },
      epic: { stones: 2000, reinforce: 20, refinement: 5 },
      legendary: { stones: 8000, reinforce: 50, refinement: 15 },
      mythic: { stones: 30000, reinforce: 100, refinement: 50, essence: 20 }
    };
    const reward = qualityRewards[equip.quality] || qualityRewards.common;
    // 强化等级额外奖励
    const enhLvl = equip.enhanceLevel || 0;
    reward.stones += enhLvl * 200;
    reward.reinforce += enhLvl * 2;
    // 移除装备
    items.splice(idx, 1);
    // 更新数据
    const updates = [
      "game_data = jsonb_set(game_data, '{items}', $2::jsonb)",
      "game_data = jsonb_set(game_data, '{spiritStones}', to_jsonb((COALESCE((game_data->>'spiritStones')::bigint, 0) + $3)::bigint))",
      "game_data = jsonb_set(game_data, '{reinforceStones}', to_jsonb((COALESCE((game_data->>'reinforceStones')::int, 0) + $4)::int))"
    ];
    const vals = [req.user.wallet, JSON.stringify(items), reward.stones, reward.reinforce];
    let idx2 = 5;
    if (reward.refinement) {
      updates.push("game_data = jsonb_set(game_data, '{refinementStones}', to_jsonb((COALESCE((game_data->>'refinementStones')::int, 0) + $" + idx2 + ")::int))");
      vals.push(reward.refinement); idx2++;
    }
    if (reward.essence) {
      updates.push("game_data = jsonb_set(game_data, '{petEssence}', to_jsonb((COALESCE((game_data->>'petEssence')::int, 0) + $" + idx2 + ")::int))");
      vals.push(reward.essence); idx2++;
    }
    await pool.query('UPDATE players SET ' + updates.join(', ') + ' WHERE wallet=$1', vals);
    res.json({ ok: true, reward, equipName: equip.name || equip.type, quality: equip.quality });
  } catch (e) { res.status(500).json({ error: safeError(e) }); }
});

// === API 文档 ===
app.get('/api/docs', (req, res) => {
  res.json({
    name: '火之文明 API',
    version: '1.0.0',
    endpoints: {
      auth: { 'POST /api/auth/login': '钱包登录(wallet,signature,message)' },
      game: {
        'POST /api/game/save': '保存游戏数据(auth)',
        'GET /api/game/load': '加载游戏数据(auth)',
        'POST /api/game/save-beacon': '离线保存(sendBeacon)'
      },
      player: {
        'POST /api/player/rename': '修改焰名(auth,newName)',
        'POST /api/gift/newplayer': '领取新手礼包(auth)',
        'POST /api/sign/daily': '每日签到(auth)'
      },
      mail: {
        'GET /api/mail/list': '邮件列表(auth)',
        'POST /api/mail/read': '标记已读(auth,mailId)',
        'POST /api/mail/claim': '领取附件(auth,mailId)',
        'POST /api/mail/delete': '删除邮件(auth,mailId)'
      },
      shop: {
        'GET /api/shop/list': '商品列表',
        'POST /api/shop/buy-equip': '购买装备(auth)',
        'POST /api/shop/buy-pill': '购买丹药(auth)',
        'POST /api/shop/buy-material': '购买材料(auth)',
        'POST /api/shop/buy-pack': '购买礼包(auth)',
        'POST /api/shop/buy-buff': '购买增益(auth)',
        'POST /api/shop/buy-herb': '购买焰草(auth)',
        'POST /api/shop/buy-formula': '购买丹方(auth)'
      },
      equipment: {
        'POST /api/equipment/enhance': '强化装备(auth,equipmentId)',
        'POST /api/equipment/reforge': '洗练装备(auth,equipmentId)'
      },
      dungeon: {
        'POST /api/dungeon/start': '开始焚天塔(auth,difficulty)',
        'POST /api/dungeon/fight': '战斗(auth)',
        'POST /api/dungeon/claim': '领取奖励(auth,floor,result,difficulty)'
      },
      exploration: {
        'GET /api/exploration/locations': '探索地点列表',
        'POST /api/exploration/explore': '探索(auth,locationId)',
        'POST /api/exploration/reward': '领取探索奖励(auth)'
      },
      gacha: {
        'POST /api/gacha/draw': '抽卡(auth,count)',
        'GET /api/gacha/probabilities': '概率公示'
      },
      boss: {
        'GET /api/boss/current': '当前Boss(auth)',
        'POST /api/boss/attack': '攻击Boss(auth)',
        'GET /api/boss/ranking': 'Boss伤害排行(auth)',
        'GET /api/boss/rewards': 'Boss奖励(auth)',
        'POST /api/boss/claim': '领取Boss奖励(auth)'
      },
      sect: {
        'GET /api/sect/list': '焰盟列表',
        'POST /api/sect/create': '创建焰盟(auth)',
        'POST /api/sect/join': '加入焰盟(auth)',
        'POST /api/sect/donate': '捐献(auth,amount)',
        'GET /api/sect/members': '成员列表(auth)'
      },
      social: {
        'GET /api/friend/list': '好友列表(auth)',
        'POST /api/friend/search': '搜索玩家(auth,keyword)',
        'POST /api/friend/add': '添加好友(auth)',
        'POST /api/friend/gift': '送礼(auth)'
      },
      auction: {
        'GET /api/auction/browse': '拍卖列表',
        'POST /api/auction/list': '上架(auth)',
        'POST /api/auction/bid': '竞拍(auth)',
        'POST /api/auction/buyout': '一口价(auth)'
      },
      leaderboard: {
        'GET /api/leaderboard/:type': '排行榜(power/level/recharge)'
      },
      vip: { 'GET /api/vip/info': 'VIP信息(auth)' },
      recharge: { 'POST /api/recharge/confirm': '充值确认(auth,txHash)' },
      stats: {
        'GET /api/stats/online': '在线玩家',
        'GET /api/stats/server': '服务器统计(admin)'
      },
      admin: {
        'POST /api/admin/mail/send': '群发邮件(admin,title,content,rewards,target)'
      },
      system: { 'GET /api/health': '健康检查' }
    }
  });
});

// === 在线统计 ===
app.get('/api/stats/online', (req, res) => {
  const players = [];
  for (const [ws, info] of onlineClients) {
    if (info.wallet) players.push({ name: info.name, wallet: info.wallet.slice(0,6) + '...' + info.wallet.slice(-4) });
  }
  res.json({ online: wss.clients.size, players });
});

app.get('/api/stats/server', auth, async (req, res) => {
  try {
    if (!ADMIN_WALLETS.includes(req.user.wallet.toLowerCase())) {
      return res.status(403).json({ error: '无权限' });
    }
    const totalPlayers = await pool.query('SELECT COUNT(*) FROM players');
    const activePlayers = await pool.query("SELECT COUNT(*) FROM players WHERE updated_at > NOW() - INTERVAL '7 days'");
    const totalMails = await pool.query('SELECT COUNT(*) FROM player_mail');
    const mem = process.memoryUsage();
    res.json({
      uptime: Math.floor(process.uptime()),
      memory: { rss: Math.round(mem.rss/1024/1024), heap: Math.round(mem.heapUsed/1024/1024) },
      wsConnections: wss.clients.size,
      authenticatedPlayers: onlineClients.size,
      totalPlayers: parseInt(totalPlayers.rows[0].count),
      activePlayers7d: parseInt(activePlayers.rows[0].count),
      totalMails: parseInt(totalMails.rows[0].count)
    });
  } catch (e) { res.status(500).json({ error: safeError(e) }); }
});

// === 邮件系统 ===
// 获取邮件列表
app.get('/api/mail/unread', auth, async (req, res) => {
  try {
    const r = await pool.query('SELECT COUNT(*) as c FROM player_mail WHERE to_wallet=$1 AND is_read=false AND (expires_at IS NULL OR expires_at > NOW())', [req.user.wallet]);
    res.json({ unread: +r.rows[0].c });
  } catch (e) { res.status(500).json({ error: safeError(e) }); }
});

app.get('/api/mail/list', auth, async (req, res) => {
  try {
    const w = req.user.wallet;
    const mails = await pool.query(
      'SELECT id, from_type, from_name, title, content, rewards, is_read, is_claimed, created_at FROM player_mail WHERE to_wallet=$1 AND (expires_at IS NULL OR expires_at > NOW()) ORDER BY created_at DESC LIMIT 50',
      [w]
    );
    const unread = await pool.query('SELECT COUNT(*) FROM player_mail WHERE to_wallet=$1 AND is_read=false AND (expires_at IS NULL OR expires_at > NOW())', [w]);
    res.json({ mails: mails.rows, unread: parseInt(unread.rows[0].count) });
  } catch (e) { res.status(500).json({ error: safeError(e) }); }
});

// 读取邮件
app.post('/api/mail/read', auth, async (req, res) => {
  try {
    const { mailId } = req.body;
    await pool.query('UPDATE player_mail SET is_read=true WHERE id=$1 AND to_wallet=$2', [mailId, req.user.wallet]);
    res.json({ ok: true });
  } catch (e) { res.status(500).json({ error: safeError(e) }); }
});

// 领取邮件附件
app.post('/api/mail/claim', auth, async (req, res) => {
  try {
    const { mailId } = req.body;
    const w = req.user.wallet;
    const mail = await pool.query('SELECT * FROM player_mail WHERE id=$1 AND to_wallet=$2', [mailId, w]);
    if (!mail.rows.length) return res.status(404).json({ error: '邮件不存在' });
    if (mail.rows[0].is_claimed) return res.status(400).json({ error: '已领取' });
    const rewards = mail.rows[0].rewards || {};
    // 发放奖励
    if (rewards.spiritStones) {
      await pool.query(
        "UPDATE players SET spirit_stones = spirit_stones + $1, game_data = jsonb_set(game_data, '{spiritStones}', to_jsonb((COALESCE((game_data->>'spiritStones')::bigint, 0) + $1)::bigint)) WHERE wallet = $2",
        [rewards.spiritStones, w]
      );
    }
    if (rewards.petEssence) {
      await pool.query(
        "UPDATE players SET game_data = jsonb_set(game_data, '{petEssence}', to_jsonb((COALESCE((game_data->>'petEssence')::int, 0) + $1)::int)) WHERE wallet = $2",
        [rewards.petEssence, w]
      );
    }
    if (rewards.reinforceStones) {
      await pool.query(
        "UPDATE players SET game_data = jsonb_set(game_data, '{reinforceStones}', to_jsonb((COALESCE((game_data->>'reinforceStones')::int, 0) + $1)::int)) WHERE wallet = $2",
        [rewards.reinforceStones, w]
      );
    }
    await pool.query('UPDATE player_mail SET is_claimed=true, is_read=true WHERE id=$1', [mailId]);
    res.json({ ok: true, rewards });
  } catch (e) { res.status(500).json({ error: safeError(e) }); }
});

// 删除邮件
app.post('/api/mail/delete', auth, async (req, res) => {
  try {
    const { mailId } = req.body;
    await pool.query('DELETE FROM player_mail WHERE id=$1 AND to_wallet=$2', [mailId, req.user.wallet]);
    res.json({ ok: true });
  } catch (e) { res.status(500).json({ error: safeError(e) }); }
});

// === 好友邮件（私信）===
app.post('/api/mail/send-friend', auth, async (req, res) => {
  try {
    const { toWallet, title, content } = req.body;
    const fromWallet = req.user.wallet;
    if (!toWallet || !content) return res.status(400).json({ error: '收件人和内容必填' });
    if (content.length > 500) return res.status(400).json({ error: '内容不能超过500字' });
    const friendship = await pool.query(
      `SELECT id FROM friendships WHERE status='accepted' AND ((from_wallet=$1 AND to_wallet=$2) OR (from_wallet=$2 AND to_wallet=$1))`,
      [fromWallet, toWallet]
    );
    if (!friendship.rows.length) return res.status(400).json({ error: '只能给好友发送邮件' });
    const recent = await pool.query(
      `SELECT COUNT(*) FROM player_mail WHERE from_wallet=$1 AND created_at > NOW() - INTERVAL '1 minute'`,
      [fromWallet]
    );
    if (parseInt(recent.rows[0].count) >= 5) return res.status(429).json({ error: '发送太频繁，请稍后再试' });
    const sender = await pool.query('SELECT name FROM players WHERE wallet=$1', [fromWallet]);
    const senderName = sender.rows[0]?.name || '无名焰修';
    const mailTitle = title || ('来自 ' + senderName + ' 的消息');
    await pool.query(
      `INSERT INTO player_mail (to_wallet, from_type, from_name, from_wallet, title, content) VALUES ($1, 'friend', $2, $3, $4, $5)`,
      [toWallet, senderName, fromWallet, mailTitle, content]
    );
    res.json({ ok: true });
  } catch (e) { res.status(500).json({ error: safeError(e) }); }
});

// 管理员发送全服邮件
app.post('/api/admin/mail/send', auth, async (req, res) => {
  try {
    if (!ADMIN_WALLETS.includes(req.user.wallet.toLowerCase())) {
      return res.status(403).json({ error: '无权限' });
    }
    const { title, content, rewards, target } = req.body;
    if (!title || !content) return res.status(400).json({ error: '标题和内容必填' });
    if (target === 'all') {
      const players = await pool.query('SELECT wallet FROM players');
      for (const p of players.rows) {
        await pool.query(
          'INSERT INTO player_mail (to_wallet, from_type, from_name, title, content, rewards) VALUES ($1, $2, $3, $4, $5, $6)',
          [p.wallet, 'admin', '管理员', title, content, JSON.stringify(rewards || {})]
        );
      }
      res.json({ ok: true, sent: players.rows.length });
    } else if (target) {
      await pool.query(
        'INSERT INTO player_mail (to_wallet, from_type, from_name, title, content, rewards) VALUES ($1, $2, $3, $4, $5, $6)',
        [target, 'admin', '管理员', title, content, JSON.stringify(rewards || {})]
      );
      res.json({ ok: true, sent: 1 });
    } else {
      res.status(400).json({ error: '需要指定 target (all 或 wallet)' });
    }
  } catch (e) { res.status(500).json({ error: safeError(e) }); }
});

// 清理过期邮件（每小时）
setInterval(async () => {
  try {
    await pool.query('DELETE FROM player_mail WHERE expires_at IS NOT NULL AND expires_at < NOW()');
  } catch {}
}, 3600000);

// ============ 404 catch-all ============
app.use('/api/*', (req, res) => {
  res.status(404).json({ error: 'API not found' });
});


// ============ 全局错误处理 ============
process.on('uncaughtException', (err) => {
  logger.error('[FATAL] uncaughtException:', err.message, err.stack);
});
process.on('unhandledRejection', (reason) => {
  logger.error('[WARN] unhandledRejection:', reason);
});



// ===== 定时任务 =====

// 拍卖过期自动结算（每5分钟）
async function settleExpiredAuctions() {
  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    const expired = await client.query(
      "SELECT * FROM auction_listings WHERE status='active' AND expires_at < NOW()"
    );
    for (const listing of expired.rows) {
      const bids = await client.query(
        'SELECT * FROM auction_bids WHERE listing_id=$1 ORDER BY amount DESC LIMIT 1',
        [listing.id]
      );
      if (bids.rows.length > 0) {
        const topBid = bids.rows[0];
        // 物品给最高出价者
        const buyerData = await client.query('SELECT game_data FROM players WHERE wallet=$1', [topBid.bidder_wallet]);
        if (buyerData.rows.length > 0) {
          const gd = buyerData.rows[0].game_data;
          const items = gd.items || [];
          items.push(listing.item_data);
          await client.query("UPDATE players SET game_data = jsonb_set(game_data, '{items}', $1::jsonb) WHERE wallet=$2",
            [JSON.stringify(items), topBid.bidder_wallet]);
        }
        // 焰晶给卖家（扣5%手续费）
        const payout = Math.floor(topBid.amount * 0.95);
        await client.query("UPDATE players SET game_data = jsonb_set(game_data, '{spiritStones}', (COALESCE((game_data->>'spiritStones')::int,0) + $1)::text::jsonb) WHERE wallet=$2",
          [payout, listing.seller_wallet]);
        await client.query("UPDATE auction_listings SET status='sold', sold_to=$1, sold_price=$2 WHERE id=$3",
          [topBid.bidder_wallet, topBid.amount, listing.id]);
      } else {
        // 无人出价，物品退还卖家
        const sellerData = await client.query('SELECT game_data FROM players WHERE wallet=$1', [listing.seller_wallet]);
        if (sellerData.rows.length > 0) {
          const gd = sellerData.rows[0].game_data;
          const items = gd.items || [];
          items.push(listing.item_data);
          await client.query("UPDATE players SET game_data = jsonb_set(game_data, '{items}', $1::jsonb) WHERE wallet=$2",
            [JSON.stringify(items), listing.seller_wallet]);
        }
        await client.query("UPDATE auction_listings SET status='expired' WHERE id=$1", [listing.id]);
      }
    }
    await client.query('COMMIT');
    if (expired.rows.length > 0) logger.info('[Auction] Settled', expired.rows.length, 'expired listings');
  } catch (e) {
    await client.query('ROLLBACK');
    logger.error('[Auction] Settlement error:', e.message);
  } finally {
    client.release();
  }
}
setInterval(settleExpiredAuctions, 5 * 60 * 1000); // 每5分钟

// 排行榜缓存刷新（每10分钟）
async function refreshLeaderboard() {
  try {
    const types = ['level', 'combat_power', 'recharge'];
    for (const t of types) {
      const col = t === 'recharge' ? 'total_recharge' : t;
      const rows = await pool.query(
        `SELECT wallet, name, ${col} as score, realm, level, combat_power, vip_level, total_recharge FROM players WHERE wallet NOT LIKE '0xbot%' ORDER BY ${col} DESC LIMIT 50`
      );
      const data = rows.rows.map((r, i) => ({ rank: i + 1, wallet: r.wallet, name: r.name, score: r.score, realm: r.realm, level: r.level, combat_power: Number(r.combat_power || 0), vip_level: r.vip_level || 0, total_recharge: r.total_recharge }));
      await pool.query(
        `INSERT INTO leaderboard_cache (type, data, updated_at) VALUES ($1, $2::jsonb, NOW())
         ON CONFLICT (type) DO UPDATE SET data = $2::jsonb, updated_at = NOW()`,
        [t, JSON.stringify(data)]
      );
    }
    logger.info('[Leaderboard] Cache refreshed');
  } catch (e) {
    logger.error('[Leaderboard] Refresh error:', e.message);
  }
}
setInterval(refreshLeaderboard, 10 * 60 * 1000);
setTimeout(refreshLeaderboard, 5000);

server.listen(PORT, '127.0.0.1', () => logger.info(`焰修后端启动 127.0.0.1:${PORT}`));




// === 月卡每日奖励自动发放（每小时检查一次） ===
setInterval(async () => {
  try {
    const now = new Date();
    // 只在每天 UTC 0-1 点执行（北京时间 8-9 点）
    if (now.getUTCHours() !== 0) return;
    const today = now.toISOString().split('T')[0];
    // 查找所有有效月卡且今天未发放的玩家
    const cards = await pool.query(
      "SELECT mc.wallet FROM monthly_cards mc WHERE mc.expires_at > NOW() AND NOT EXISTS (SELECT 1 FROM player_mail pm WHERE pm.to_wallet = mc.wallet AND pm.title = '🌙 月卡每日奖励' AND pm.created_at::date = CURRENT_DATE)"
    );
    for (const card of cards.rows) {
      await pool.query(
        "INSERT INTO player_mail (to_wallet, from_type, from_name, title, content, rewards) VALUES ($1, 'system', '月卡', '🌙 月卡每日奖励', '月卡每日奖励已送达，请查收！', $2)",
        [card.wallet, JSON.stringify({ spiritStones: 5000 })]
      );
    }
    if (cards.rows.length > 0) logger.info('[MonthlyCard]', cards.rows.length, 'daily rewards sent');
  } catch (e) { logger.error('[MonthlyCard error]', e.message); }
}, 3600000);

// === 自动清理过期数据（每6小时） ===
setInterval(async () => {
  try {
    // 清理30天前的PK记录
    const pk = await pool.query("DELETE FROM pk_records WHERE created_at < NOW() - INTERVAL '30 days'");
    // 清理过期月卡记录
    const mc = await pool.query("DELETE FROM monthly_cards WHERE expires_at < NOW() - INTERVAL '7 days'");
    // 清理已读且已领取的30天前邮件
    const mail = await pool.query("DELETE FROM player_mail WHERE is_read=true AND is_claimed=true AND created_at < NOW() - INTERVAL '30 days'");
    // 清理过期拍卖历史（60天前）
    const ah = await pool.query("DELETE FROM auction_history WHERE created_at < NOW() - INTERVAL '60 days'");
    const total = (pk.rowCount||0) + (mc.rowCount||0) + (mail.rowCount||0) + (ah.rowCount||0);
    if (total > 0) logger.info('[Cleanup]', total, 'expired records removed');
  } catch (e) { logger.error('[Cleanup error]', e.message); }
}, 6 * 3600000);

// Graceful shutdown
function gracefulShutdown(signal) {
  logger.info('[Server] Received', signal, '- shutting down gracefully...');
  wss.clients.forEach(c => c.close(1001, 'Server shutting down'));
  server.close(() => {
    pool.end().then(() => {
      logger.info('[Server] Shutdown complete');
      process.exit(0);
    });
  });
  setTimeout(() => process.exit(1), 10000); // 10s 强制退出
}
process.on('SIGTERM', () => gracefulShutdown('SIGTERM'));
process.on('SIGINT', () => gracefulShutdown('SIGINT'));
