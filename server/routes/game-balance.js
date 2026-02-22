import logger from "../services/logger.js";
import { Router } from 'express';
import jwt from 'jsonwebtoken';
import { getConfig, setConfig, getAllConfig, reloadConfig } from '../game-config.js';
import pool from '../db.js';

const router = Router();
const JWT_SECRET = process.env.JWT_SECRET || 'xiuxian_jwt_secret_2026';
const ADMIN_WALLET = '0xfad7eb0814b6838b05191a07fb987957d50c4ca9';

// 管理员认证中间件
function adminAuth(req, res, next) {
  const header = req.headers.authorization;
  if (!header) {
    return res.status(401).json({ error: '未提供认证令牌' });
  }
  
  const token = header.replace('Bearer ', '');
  
  try {
    const decoded = jwt.verify(token, JWT_SECRET);
    const wallet = (decoded.walletAddress || decoded.wallet || '').toLowerCase();
    
    if (wallet !== ADMIN_WALLET.toLowerCase()) {
      return res.status(403).json({ error: '无权访问' });
    }
    
    req.user = { wallet };
    next();
  } catch (e) {
    return res.status(401).json({ error: '令牌无效或已过期' });
  }
}

// GET /api/admin/balance - 获取所有配置
router.get('/balance', adminAuth, async (req, res) => {
  try {
    const config = await getAllConfig();
    res.json({
      success: true,
      config
    });
  } catch (e) {
    logger.error('Get balance config error:', e);
    res.status(500).json({ error: e.message });
  }
});

// PUT /api/admin/balance/:key - 修改单个配置
router.put('/balance/:key', adminAuth, async (req, res) => {
  try {
    const { key } = req.params;
    const value = req.body;
    
    // 验证key是否合法
    const validKeys = [
      'gacha_equip_probs', 'gacha_pet_probs', 'gacha_cost', 'gacha_limits',
      'gacha_pity', 'exploration_reward_multiplier', 'exploration_cooldown',
      'pill_fragment_chance', 'shop_price_multiplier', 'shop_limits', 'material_prices'
    ];
    
    if (!validKeys.includes(key)) {
      return res.status(400).json({ error: '无效的配置键' });
    }
    
    await setConfig(key, value);
    
    res.json({
      success: true,
      message: `配置 ${key} 已更新`,
      key,
      value
    });
  } catch (e) {
    logger.error('Set balance config error:', e);
    res.status(500).json({ error: e.message });
  }
});

// POST /api/admin/balance/reload - 重新加载配置
router.post('/balance/reload', adminAuth, async (req, res) => {
  try {
    const count = await reloadConfig();
    res.json({
      success: true,
      message: `已重新加载 ${count} 个配置项`,
      loadedCount: count
    });
  } catch (e) {
    logger.error('Reload config error:', e);
    res.status(500).json({ error: e.message });
  }
});

// GET /api/admin/balance/stats - 获取全服统计
router.get('/balance/stats', adminAuth, async (req, res) => {
  try {
    // 获取所有玩家数据
    const result = await pool.query('SELECT game_data FROM players');
    
    let mythicEquipCount = 0;
    let divinePetCount = 0;
    let legendaryEquipCount = 0;
    let celestialPetCount = 0;
    const mythicPerSlot = {};
    
    for (const row of result.rows) {
      if (!row.game_data) continue;
      
      const gameData = typeof row.game_data === 'string' 
        ? JSON.parse(row.game_data) 
        : row.game_data;
      
      const items = gameData.items || [];
      
      for (const item of items) {
        // 统计仙品装备
        if (item.quality === 'mythic' && item.type !== 'pet') {
          mythicEquipCount++;
          const slot = item.slot || item.type;
          mythicPerSlot[slot] = (mythicPerSlot[slot] || 0) + 1;
        }
        // 统计极品装备
        if (item.quality === 'legendary' && item.type !== 'pet') {
          legendaryEquipCount++;
        }
        // 统计神品焰兽
        if (item.rarity === 'divine' && item.type === 'pet') {
          divinePetCount++;
        }
        // 统计仙品焰兽
        if (item.rarity === 'celestial' && item.type === 'pet') {
          celestialPetCount++;
        }
      }
    }
    
    // 获取当前配置
    const gachaLimits = await getConfig('gacha_limits');
    
    res.json({
      success: true,
      stats: {
        equipment: {
          mythic: {
            total: mythicEquipCount,
            perSlot: mythicPerSlot,
            limitPerSlot: gachaLimits?.mythic_per_slot || 50
          },
          legendary: {
            total: legendaryEquipCount
          }
        },
        pets: {
          divine: {
            total: divinePetCount,
            limit: gachaLimits?.divine_pets || 20
          },
          celestial: {
            total: celestialPetCount
          }
        }
      }
    });
  } catch (e) {
    logger.error('Get balance stats error:', e);
    res.status(500).json({ error: e.message });
  }
});

export default router;
