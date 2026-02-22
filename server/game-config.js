import pool from './db.js';

// 默认配置
const DEFAULTS = {
  // 抽卡装备概率
  gacha_equip_probs: {
    common: 0.40,
    uncommon: 0.30,
    rare: 0.18,
    epic: 0.08,
    legendary: 0.03,
    mythic: 0.005
  },
  
  // 抽卡焰兽概率
  gacha_pet_probs: {
    divine: 0.001,
    celestial: 0.03,
    mystic: 0.15,
    spiritual: 0.32,
    mortal: 0.499
  },
  
  // 抽卡费用
  gacha_cost: {
    normal: 100,
    wishlist: 200
  },
  
  // 全服限量（-1 表示不限）
  gacha_limits: {
    mythic_per_slot: 50,    // 仙品装备每槽位全服限量
    divine_pets: 20         // 神品焰兽全服限量
  },
  
  // 保底系统
  gacha_pity: {
    epic_guarantee: 50,          // 50抽保底 epic+
    legendary_guarantee: 100,    // 100抽保底 legendary+
    mythic_guarantee: -1,    // 仙品无保底，纯概率       // 200抽保底 mythic（无视限量）
    pet_mystic_guarantee: 80,    // 80抽保底 mystic+ 焰兽
    pet_celestial_guarantee: 200 // 200抽保底 celestial+ 焰兽
  },
  
  // 探索收益倍率
  exploration_reward_multiplier: {
    spirit_stone: 0.65,  // 焰晶收益降到65%
    herb: 1.0,
    cultivation: 1.0,
    pill_fragment: 1.0
  },
  
  // 探索冷却（秒）
  exploration_cooldown: 30,
  
  // 丹方残页掉率
  pill_fragment_chance: 0.12,
  
  // 商城价格倍率
  shop_price_multiplier: 1.0,
  
  // 商城限购
  shop_limits: {
    legendary_equip_per_week: 1,  // 极品装备每人每周限购1件
    mythic_equip_enabled: false   // 仙品装备商城下架
  },
  
  // 材料价格
  material_prices: {
    reinforce_stone: 1000,
    reinforce_stone_10: 9000,
    refine_stone: 1500,
    refine_stone_10: 13500
  }
};

// 内存缓存
const cache = new Map();

// 初始化缓存
async function initCache() {
  try {
    const result = await pool.query('SELECT key, value FROM settings');
    for (const row of result.rows) {
      cache.set(row.key, row.value);
    }
    console.log(`[GameConfig] Loaded ${cache.size} config items from DB`);
  } catch (e) {
    console.error('[GameConfig] Failed to init cache:', e.message);
  }
}

// 获取配置
async function getConfig(key) {
  // 先查缓存
  if (cache.has(key)) {
    return cache.get(key);
  }
  
  // 缓存未命中，查DB
  try {
    const result = await pool.query('SELECT value FROM settings WHERE key = $1', [key]);
    if (result.rows.length > 0) {
      const value = result.rows[0].value;
      cache.set(key, value);
      return value;
    }
  } catch (e) {
    console.error(`[GameConfig] Failed to get ${key}:`, e.message);
  }
  
  // 返回默认值
  return DEFAULTS[key];
}

// 设置配置
async function setConfig(key, value) {
  try {
    await pool.query(
      'INSERT INTO settings (key, value, updated_at) VALUES ($1, $2, NOW()) ' +
      'ON CONFLICT (key) DO UPDATE SET value = $2, updated_at = NOW()',
      [key, JSON.stringify(value)]
    );
    cache.set(key, value);
    return true;
  } catch (e) {
    console.error(`[GameConfig] Failed to set ${key}:`, e.message);
    throw e;
  }
}

// 获取所有配置
async function getAllConfig() {
  const result = { ...DEFAULTS };
  
  // 覆盖DB中的值
  for (const [key, value] of cache.entries()) {
    result[key] = value;
  }
  
  return result;
}

// 重新加载配置
async function reloadConfig() {
  cache.clear();
  await initCache();
  return cache.size;
}

// 初始化
initCache();

export {
  DEFAULTS,
  getConfig,
  setConfig,
  getAllConfig,
  reloadConfig
};

export default {
  DEFAULTS,
  getConfig,
  setConfig,
  getAllConfig,
  reloadConfig
};
