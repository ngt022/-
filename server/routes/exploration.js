import express from 'express';
import { getConfig } from '../game-config.js';

const router = express.Router();

// 地点配置
const locations = [
  {
    id: 'newbie_village',
    name: '薪火村',
    description: '焰气初生之地，适合初入修焰之道的焰修。',
    minLevel: 1,
    spiritCost: 50,
    rewards: [
      { type: 'spirit_stone', chance: 0.3, amount: [1, 2] },
      { type: 'herb', chance: 0.3, amount: [1, 2] },
      { type: 'cultivation', chance: 0.2, amount: [5, 10] },
      { type: 'pill_fragment', chance: 0.2, amount: [1, 1] }
    ]
  },
  {
    id: 'celestial_mountain',
    name: '赤霄峰',
    description: '赤焰缭绕的焰山，传说是远古焰仙讲道之地。',
    minLevel: 10,
    spiritCost: 300,
    rewards: [
      { type: 'spirit_stone', chance: 0.25, amount: [20, 40] },
      { type: 'herb', chance: 0.3, amount: [15, 25] },
      { type: 'cultivation', chance: 0.25, amount: [150, 300] },
      { type: 'pill_fragment', chance: 0.2, amount: [6, 10] }
    ]
  },
  {
    id: 'phoenix_valley',
    name: '涅槃谷',
    description: '常年被烈焰环绕的神秘山谷，据说有凤凰涅槃遗留的焰韵。',
    minLevel: 19,
    spiritCost: 500,
    rewards: [
      { type: 'spirit_stone', chance: 0.25, amount: [35, 70] },
      { type: 'herb', chance: 0.3, amount: [20, 35] },
      { type: 'cultivation', chance: 0.25, amount: [250, 500] },
      { type: 'pill_fragment', chance: 0.2, amount: [8, 12] }
    ]
  },
  {
    id: 'dragon_abyss',
    name: '焰渊',
    description: '深不见底的神秘深渊，蕴含远古焰龙的气息。',
    minLevel: 28,
    spiritCost: 750,
    rewards: [
      { type: 'spirit_stone', chance: 0.25, amount: [50, 100] },
      { type: 'herb', chance: 0.3, amount: [30, 50] },
      { type: 'cultivation', chance: 0.25, amount: [400, 800] },
      { type: 'pill_fragment', chance: 0.2, amount: [10, 15] }
    ]
  },
  {
    id: 'immortal_realm',
    name: '焰天圣域入口',
    description: '焰气最为浓郁的至高圣域，唯有化焰期以上的焰修方可踏入。',
    minLevel: 37,
    spiritCost: 1000,
    rewards: [
      { type: 'spirit_stone', chance: 0.25, amount: [80, 180] },
      { type: 'herb', chance: 0.3, amount: [50, 100] },
      { type: 'cultivation', chance: 0.25, amount: [800, 1500] },
      { type: 'pill_fragment', chance: 0.2, amount: [15, 20] }
    ]
  },
  {
    id: 'void_realm',
    name: '焰虚秘境',
    description: '虚空与焰气交织的异度空间，时间在此扭曲，蕴含无尽焰道奥秘。',
    minLevel: 46,
    spiritCost: 1500,
    rewards: [
      { type: 'spirit_stone', chance: 0.25, amount: [120, 250] },
      { type: 'herb', chance: 0.3, amount: [70, 130] },
      { type: 'cultivation', chance: 0.25, amount: [1200, 2500] },
      { type: 'pill_fragment', chance: 0.2, amount: [18, 25] }
    ]
  },
  {
    id: 'fusion_forbidden',
    name: '焰合禁地',
    description: '远古焰帝封印之地，焰气浓郁到凝为实质，踏入者需有焰合之力方可自保。',
    minLevel: 55,
    spiritCost: 2000,
    rewards: [
      { type: 'spirit_stone', chance: 0.25, amount: [180, 400] },
      { type: 'herb', chance: 0.3, amount: [100, 180] },
      { type: 'cultivation', chance: 0.25, amount: [2000, 4000] },
      { type: 'pill_fragment', chance: 0.2, amount: [22, 30] }
    ]
  },
  {
    id: 'great_flame_palace',
    name: '大焰天宫',
    description: '悬浮于九天之上的焰之宫殿，传说是焰帝飞升前的修炼圣地。',
    minLevel: 73,
    spiritCost: 3000,
    rewards: [
      { type: 'spirit_stone', chance: 0.25, amount: [300, 600] },
      { type: 'herb', chance: 0.3, amount: [150, 250] },
      { type: 'cultivation', chance: 0.25, amount: [3500, 7000] },
      { type: 'pill_fragment', chance: 0.2, amount: [28, 38] }
    ]
  },
  {
    id: 'tribulation_temple',
    name: '渡焰圣殿',
    description: '焰道尽头的终极试炼之地，唯有渡过焰劫者方能窥见大道真谛。',
    minLevel: 91,
    spiritCost: 5000,
    rewards: [
      { type: 'spirit_stone', chance: 0.25, amount: [500, 1000] },
      { type: 'herb', chance: 0.3, amount: [200, 350] },
      { type: 'cultivation', chance: 0.25, amount: [6000, 12000] },
      { type: 'pill_fragment', chance: 0.2, amount: [35, 50] }
    ]
  }
];

// 随机事件配置
const events = [
  {
    id: 'ancient_tablet',
    name: '古老石碑',
    description: '发现一块刻有上古功法的石碑。',
    chance: 0.08,
    effect: 'cultivation_bonus'
  },
  {
    id: 'spirit_spring',
    name: '灵泉',
    description: '偶遇一处天然灵泉。',
    chance: 0.12,
    effect: 'spirit_bonus'
  },
  {
    id: 'ancient_master',
    name: '古修遗府',
    description: '意外发现一位上古大能的洞府。',
    chance: 0.03,
    effect: 'double_bonus'
  },
  {
    id: 'monster_attack',
    name: '黑焰兽袭击',
    description: '遭遇一只实力强大的黑焰兽。',
    chance: 0.15,
    effect: 'spirit_damage'
  },
  {
    id: 'cultivation_deviation',
    name: '走火入魔',
    description: '修炼出现偏差，走火入魔。',
    chance: 0.12,
    effect: 'cultivation_damage'
  },
  {
    id: 'treasure_trove',
    name: '焰域宝藏',
    description: '发现一处上古修士遗留的宝藏。',
    chance: 0.05,
    effect: 'stone_bonus'
  },
  {
    id: 'enlightenment',
    name: '顿悟',
    description: '修炼中突然顿悟。',
    chance: 0.08,
    effect: 'enlightenment'
  },
  {
    id: 'qi_deviation',
    name: '心魔侵扰',
    description: '遭受心魔侵扰，修为受损。',
    chance: 0.15,
    effect: 'double_damage'
  }
];

// 焰草品质配置
const herbQualities = {
  common: { name: '普通', multiplier: 1, color: '#9e9e9e' },
  uncommon: { name: '优质', multiplier: 1.5, color: '#4caf50' },
  rare: { name: '稀有', multiplier: 2, color: '#2196f3' },
  epic: { name: '史诗', multiplier: 3, color: '#9c27b0' },
  legendary: { name: '传说', multiplier: 5, color: '#ff9800' }
};

// 新的焰草类型配置 - 15种草，按baseValue分层
const herbTypes = [
  { id: 'spirit_grass', name: '灵精草', baseValue: 10 },      // 低级
  { id: 'cloud_flower', name: '云雾花', baseValue: 15 },      // 低级
  { id: 'thunder_root', name: '雷击根', baseValue: 25 },      // 中低级
  { id: 'fire_heart_flower', name: '火心花', baseValue: 35 }, // 中低级
  { id: 'dragon_breath_herb', name: '龙息草', baseValue: 40 }, // 中级
  { id: 'nine_leaf_lingzhi', name: '九叶灵芝', baseValue: 45 }, // 中级
  { id: 'purple_ginseng', name: '紫金参', baseValue: 50 },    // 中级
  { id: 'frost_lotus', name: '寒霜莲', baseValue: 55 },       // 中级
  { id: 'immortal_jade_grass', name: '仙玉草', baseValue: 60 }, // 中高级
  { id: 'dark_yin_grass', name: '玄阴草', baseValue: 30 },    // 中低级
  { id: 'moonlight_orchid', name: '月华兰', baseValue: 70 },  // 高级
  { id: 'sun_essence_flower', name: '日精花', baseValue: 75 }, // 高级
  { id: 'five_elements_grass', name: '五行草', baseValue: 80 }, // 高级
  { id: 'phoenix_feather_herb', name: '凤羽草', baseValue: 85 }, // 高级
  { id: 'celestial_dew_grass', name: '天露草', baseValue: 90 }, // 顶级
];

// 按等级分层草类型（用于不同地图掉落）
const herbTiers = {
  1: ['spirit_grass', 'cloud_flower', 'dark_yin_grass'],                                    // 低级草
  2: ['spirit_grass', 'cloud_flower', 'thunder_root', 'fire_heart_flower', 'dark_yin_grass'], // 中低级草
  3: ['thunder_root', 'dragon_breath_herb', 'nine_leaf_lingzhi', 'fire_heart_flower', 'purple_ginseng'], // 中级草
  4: ['purple_ginseng', 'frost_lotus', 'immortal_jade_grass', 'nine_leaf_lingzhi', 'dragon_breath_herb'], // 中高级草
  5: ['moonlight_orchid', 'sun_essence_flower', 'five_elements_grass', 'phoenix_feather_herb', 'celestial_dew_grass'], // 高级草
};

// 地图对应的草等级
const locationHerbTier = {
  'newbie_village': 1,      // 薪火村 - 低级
  'celestial_mountain': 2,  // 赤霄峰 - 中低级
  'phoenix_valley': 3,      // 涅槃谷 - 中级
  'dragon_abyss': 4,        // 焰渊 - 中高级
  'immortal_realm': 5,      // 焰天圣域入口 - 高级
  'void_realm': 6,          // 焰虚秘境 - 超高级
  'fusion_forbidden': 7,    // 焰合禁地 - 极高级
  'great_flame_palace': 8,  // 大焰天宫 - 顶级
  'tribulation_temple': 9,  // 渡焰圣殿 - 至尊级
};

// 丹方配置
const pillRecipes = [
  { id: 'spirit_gathering', name: '聚灵丹' },
  { id: 'cultivation_boost', name: '聚气丹' },
  { id: 'thunder_power', name: '雷灵丹' },
  { id: 'immortal_essence', name: '仙灵丹' },
  { id: 'five_elements_pill', name: '五行丹' },
  { id: 'celestial_essence_pill', name: '天元丹' },
  { id: 'sun_moon_pill', name: '日月丹' },
  { id: 'phoenix_rebirth_pill', name: '涅槃丹' },
  { id: 'spirit_recovery', name: '回灵丹' },
  { id: 'essence_condensation', name: '凝元丹' },
  { id: 'mind_clarity', name: '清心丹' },
  { id: 'fire_essence', name: '火元丹' }
];

// 获取随机奖励
async function getRandomReward(rewards, luck = 1) {
  // 获取配置
  const rewardMultiplier = await getConfig('exploration_reward_multiplier') || { spirit_stone: 0.65, herb: 1.0, cultivation: 1.0, pill_fragment: 1.0 };
  const pillFragmentChance = await getConfig('pill_fragment_chance') || 0.12;
  
  const rand = Math.random();
  let cumulative = 0;
  
  for (const reward of rewards) {
    // 根据奖励类型调整概率
    let chance = reward.chance;
    if (reward.type === 'pill_fragment') {
      chance = pillFragmentChance;
    }
    cumulative += chance * luck;
    
    if (rand <= cumulative) {
      let amount = Math.floor(Math.random() * (reward.amount[1] - reward.amount[0] + 1)) + reward.amount[0];
      
      // 应用收益倍率
      const multiplier = rewardMultiplier[reward.type] || 1;
      amount = Math.floor(amount * multiplier);
      
      return { type: reward.type, amount };
    }
  }
  return null;
}

// 获取随机事件
function getRandomEvent() {
  for (const event of events) {
    if (Math.random() <= event.chance) {
      return event;
    }
  }
  return null;
}

// 获取随机焰草（带幸运符效果）
function getRandomHerb(locationId, luckyCharmActive = false) {
  // 确定草的品质
  let rand = Math.random();
  
  // 幸运符效果：提升稀有品质概率
  if (luckyCharmActive) {
    rand = rand * 0.7; // 30%的概率提升
  }
  
  let quality = 'common';
  if (rand > 0.95) quality = 'legendary';
  else if (rand > 0.85) quality = 'epic';
  else if (rand > 0.65) quality = 'rare';
  else if (rand > 0.40) quality = 'uncommon';
  
  // 根据地图获取对应等级的草
  const tier = locationHerbTier[locationId] || 1;
  const availableHerbIds = herbTiers[tier];
  const randomHerbId = availableHerbIds[Math.floor(Math.random() * availableHerbIds.length)];
  const herbType = herbTypes.find(h => h.id === randomHerbId);
  const qualityData = herbQualities[quality];
  
  return {
    id: Date.now() + Math.random().toString(36).substr(2, 9),
    herbId: herbType.id,
    name: herbType.name,
    quality: quality,
    value: Math.floor(herbType.baseValue * qualityData.multiplier),
    obtainedAt: Date.now()
  };
}

// 检查buff是否有效
function isBuffActive(buffData, buffKey) {
  if (!buffData || !buffData[buffKey]) return false;
  return buffData[buffKey] > Date.now();
}

// POST /api/exploration/explore - 执行探索
export default function(pool, auth) {
  router.post('/explore', auth, async (req, res) => {
    try {
      const { locationId } = req.body;
      const wallet = req.user.wallet;

      if (!locationId) {
        return res.status(400).json({ error: '参数无效' });
      }

      // 查找地点配置
      const location = locations.find(l => l.id === locationId);
      if (!location) {
        return res.status(400).json({ error: '地点不存在' });
      }

      // 获取玩家数据
      const playerResult = await pool.query('SELECT game_data, level, name, id FROM players WHERE wallet = $1', [wallet]);
      if (playerResult.rows.length === 0) {
        return res.status(404).json({ error: '玩家不存在' });
      }

      const player = playerResult.rows[0];
      const gameData = typeof player.game_data === 'string' ? JSON.parse(player.game_data) : (player.game_data || {});
      const playerLevel = player.level || gameData.level || 1;
      const playerLuck = gameData.luck || 1;
      const currentSpirit = gameData.spirit || 0;
      const currentStones = gameData.spiritStones ?? player.spirit_stones ?? 0;
      
      // 检查探索冷却
      const cooldownSeconds = await getConfig('exploration_cooldown') || 30;
      const now = Date.now();
      const lastExploreTime = gameData.lastExploreTime || 0;
      const elapsedSeconds = (now - lastExploreTime) / 1000;
      
      if (elapsedSeconds < cooldownSeconds) {
        const remainingSeconds = Math.ceil(cooldownSeconds - elapsedSeconds);
        return res.status(400).json({ 
          error: '探索冷却中', 
          remainingSeconds,
          message: `探索过于频繁，请${remainingSeconds}秒后再试`
        });
      }
      
      // 更新上次探索时间
      gameData.lastExploreTime = now;
      
      // 检查buff状态
      const buffs = gameData.buffs || {};
      const doubleCrystalActive = isBuffActive(buffs, 'doubleCrystal');
      const cultivationBoostActive = isBuffActive(buffs, 'cultivationBoost');
      const luckyCharmActive = isBuffActive(buffs, 'luckyCharm');

      // VIP加成
      const vipRow = await pool.query('SELECT vip_level FROM players WHERE wallet=$1', [wallet]);
      const vipLevel = vipRow.rows[0]?.vip_level || 0;
      const VIP_BOOSTS = [
        { cultivationBoost:1, extraDrop:0 },
        { cultivationBoost:1.1, extraDrop:0.05 },
        { cultivationBoost:1.2, extraDrop:0.1 },
        { cultivationBoost:1.5, extraDrop:0.15 },
        { cultivationBoost:1.8, extraDrop:0.2 },
        { cultivationBoost:2.0, extraDrop:0.3 }
      ];
      const vipBoost = VIP_BOOSTS[Math.min(vipLevel, 5)];

      // 检查等级要求
      if (playerLevel < location.minLevel) {
        return res.status(400).json({ error: '等级不足' });
      }

      // 检查焰灵
      if (currentSpirit < location.spiritCost) {
        return res.status(400).json({ error: '焰灵不足' });
      }

      // 扣除焰灵
      const newSpirit = currentSpirit - location.spiritCost;
      gameData.spirit = newSpirit;

      // 增加探索次数
      gameData.explorationCount = (gameData.explorationCount || 0) + 1;

      // 检查是否触发随机事件
      const event = getRandomEvent();
      let eventResult = null;
      let cultivationBonus = 0;
      let spiritBonus = 0;
      let stoneBonus = 0;

      if (event) {
        eventResult = {
          id: event.id,
          name: event.name,
          description: event.description
        };

        // 根据事件类型计算效果
        switch (event.effect) {
          case 'cultivation_bonus':
            cultivationBonus = Math.floor(30 * (playerLevel / 5 + 1));
            // 修炼加速buff效果
            if (cultivationBoostActive) {
              cultivationBonus = Math.floor(cultivationBonus * 1.5);
            }
            gameData.cultivation = (gameData.cultivation || 0) + cultivationBonus;
            eventResult.effect = { type: 'cultivation', amount: cultivationBonus };
            break;
          case 'spirit_bonus':
            spiritBonus = Math.floor(60 * (playerLevel / 3 + 1));
            gameData.spirit = (gameData.spirit || 0) + spiritBonus;
            eventResult.effect = { type: 'spirit', amount: spiritBonus };
            break;
          case 'double_bonus':
            cultivationBonus = Math.floor(120 * (playerLevel / 2 + 1));
            spiritBonus = Math.floor(180 * (playerLevel / 2 + 1));
            // 修炼加速buff效果
            if (cultivationBoostActive) {
              cultivationBonus = Math.floor(cultivationBonus * 1.5);
            }
            gameData.cultivation = (gameData.cultivation || 0) + cultivationBonus;
            gameData.spirit = (gameData.spirit || 0) + spiritBonus;
            eventResult.effect = { type: 'double', cultivation: cultivationBonus, spirit: spiritBonus };
            break;
          case 'spirit_damage':
            const spiritDamage = Math.floor(80 * (playerLevel / 4 + 1));
            gameData.spirit = Math.max(0, (gameData.spirit || 0) - spiritDamage);
            eventResult.effect = { type: 'damage', spirit: spiritDamage };
            break;
          case 'cultivation_damage':
            const cultDamage = Math.floor(50 * (playerLevel / 3 + 1));
            gameData.cultivation = Math.max(0, (gameData.cultivation || 0) - cultDamage);
            eventResult.effect = { type: 'damage', cultivation: cultDamage };
            break;
          case 'stone_bonus':
            stoneBonus = Math.floor(30 * (playerLevel / 2 + 1));
            // 焰晶双倍buff效果
            if (doubleCrystalActive) {
              stoneBonus = stoneBonus * 2;
            }
            gameData.spiritStones = currentStones + stoneBonus;
            eventResult.effect = { type: 'stones', amount: stoneBonus };
            break;
          case 'enlightenment':
            cultivationBonus = Math.floor(50 * (playerLevel / 4 + 1));
            // 修炼加速buff效果
            if (cultivationBoostActive) {
              cultivationBonus = Math.floor(cultivationBonus * 1.5);
            }
            gameData.cultivation = (gameData.cultivation || 0) + cultivationBonus;
            gameData.spiritRate = (gameData.spiritRate || 1) * 1.05;
            eventResult.effect = { type: 'enlightenment', cultivation: cultivationBonus };
            break;
          case 'double_damage':
            const ddSpirit = Math.floor(60 * (playerLevel / 3 + 1));
            const ddCult = Math.floor(60 * (playerLevel / 3 + 1));
            gameData.spirit = Math.max(0, (gameData.spirit || 0) - ddSpirit);
            gameData.cultivation = Math.max(0, (gameData.cultivation || 0) - ddCult);
            eventResult.effect = { type: 'damage', spirit: ddSpirit, cultivation: ddCult };
            break;
        }
      }

      // 应用VIP修为加成
      if (cultivationBonus > 0 && vipBoost.cultivationBoost > 1) {
        const vipExtra = Math.floor(cultivationBonus * (vipBoost.cultivationBoost - 1));
        cultivationBonus += vipExtra;
        gameData.cultivation = (gameData.cultivation || 0) + vipExtra;
      }

      // 生成奖励
      let reward = null;
      if (!event || event.effect === 'stone_bonus') {
        // 如果触发了宝藏事件，额外给奖励
        reward = await getRandomReward(location.rewards, playerLuck + vipBoost.extraDrop);
        
        if (reward) {
          switch (reward.type) {
            case 'spirit_stone':
              let stoneAmount = reward.amount;
              // 焰晶双倍buff效果
              if (doubleCrystalActive) {
                stoneAmount = stoneAmount * 2;
              }
              gameData.spiritStones = (gameData.spiritStones || currentStones) + stoneAmount;
              reward.name = '焰晶';
              reward.amount = stoneAmount; // 更新显示数量
              break;
            case 'herb':
              if (!gameData.herbs) gameData.herbs = [];
              for (let i = 0; i < reward.amount; i++) {
                const herb = getRandomHerb(locationId, luckyCharmActive);
                gameData.herbs.push(herb);
              }
              reward.name = '焰草';
              break;
            case 'cultivation':
              let cultAmount = reward.amount;
              // 修炼加速buff效果
              if (cultivationBoostActive) {
                cultAmount = Math.floor(cultAmount * 1.5);
              }
              // VIP修为加成
              if (vipBoost.cultivationBoost > 1) {
                cultAmount = Math.floor(cultAmount * vipBoost.cultivationBoost);
              }
              gameData.cultivation = (gameData.cultivation || 0) + cultAmount;
              reward.name = '修为';
              reward.amount = cultAmount; // 更新显示数量
              break;
            case 'pill_fragment':
              if (!gameData.pillFragments) gameData.pillFragments = {};
              for (let i = 0; i < reward.amount; i++) {
                const randomRecipe = pillRecipes[Math.floor(Math.random() * pillRecipes.length)];
                gameData.pillFragments[randomRecipe.id] = (gameData.pillFragments[randomRecipe.id] || 0) + 1;
              }
              reward.name = '丹方残页';
              break;
          }
        }
      }

      // 保存到数据库
      await pool.query(
        'UPDATE players SET game_data = $1, spirit_stones = COALESCE((game_data->>\'spiritStones\')::bigint, spirit_stones) WHERE wallet = $2',
        [JSON.stringify(gameData), wallet]
      );
      
      // 重新获取spirit_stones
      const updatedPlayer = await pool.query('SELECT spirit_stones, game_data FROM players WHERE wallet = $1', [wallet]);
      const updatedGameData = typeof updatedPlayer.rows[0].game_data === 'string' 
        ? JSON.parse(updatedPlayer.rows[0].game_data) 
        : updatedPlayer.rows[0].game_data;

      res.json({
        success: true,
        reward: reward,
        event: eventResult,
        buffs: {
          doubleCrystal: doubleCrystalActive,
          cultivationBoost: cultivationBoostActive,
          luckyCharm: luckyCharmActive
        },
        vipLevel,
        spiritStones: updatedGameData.spiritStones ?? updatedPlayer.rows[0].spirit_stones ?? 0,
        spirit: updatedGameData.spirit ?? 0,
        cultivation: updatedGameData.cultivation ?? 0
      });
    } catch (e) {
      res.status(500).json({ error: e.message });
    }
  });

  // 获取地点列表
  router.get('/locations', (req, res) => {
    res.json({ locations });
  });

  return router;
}
