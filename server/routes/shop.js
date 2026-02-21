import express from 'express';
import { generateEquipment, generatePet, equipmentQualities, equipmentTypes } from './gacha.js';
import { getConfig } from '../game-config.js';

const router = express.Router();

const EQUIP_PRICES = { rare: 2000, epic: 8000, legendary: 30000, mythic: 100000 };

const SLOT_NAMES = {
  weapon:'武器',head:'头部',body:'衣服',legs:'裤子',feet:'鞋子',shoulder:'肩甲',
  hands:'手套',wrist:'护腕',necklace:'焰心链',ring1:'符文戒1',ring2:'符文戒2',belt:'腰带',artifact:'焰器'
};

const PILL_ITEMS = {
  spirit_small:  { price:500,   name:'小灵力药水', effect:'spirit',  value:500 },
  spirit_medium: { price:2000,  name:'中灵力药水', effect:'spirit',  value:2500 },
  spirit_large:  { price:8000,  name:'大灵力药水', effect:'spirit',  value:12000 },
  cult_small:    { price:1000,  name:'小修为丹',   effect:'cultivation', multiplier:100 },
  cult_medium:   { price:5000,  name:'中修为丹',   effect:'cultivation', multiplier:600 },
  cult_large:    { price:20000, name:'大修为丹',   effect:'cultivation', multiplier:3000 },
  exp_1:  { price:50000,  name:'1级经验丹', effect:'levelup', levels:1 },
  exp_5:  { price:200000, name:'5级经验丹', effect:'levelup', levels:5 },
  exp_10: { price:500000, name:'10级经验丹',effect:'levelup', levels:10 },
  attr_attack:  { price:3000, name:'攻击丹', effect:'attr', stat:'attack',  value:50 },
  attr_health:  { price:3000, name:'生命丹', effect:'attr', stat:'health',  value:500 },
  attr_defense: { price:3000, name:'防御丹', effect:'attr', stat:'defense', value:30 },
  attr_speed:   { price:3000, name:'速度丹', effect:'attr', stat:'speed',   value:20 },
};

// 材料价格从配置读取，这里保留默认价格配置
const DEFAULT_MATERIAL_PRICES = {
  reinforce_1: 1000,
  reinforce_10: 9000,
  refine_1: 1500,
  refine_10: 13500,
  pet_essence: 2000,
  pet_ticket: 5000,
  pill_frag_health: 1000,
  pill_frag_attack: 1500,
  pill_frag_defense: 1500,
  pill_frag_speed: 1200,
};

const MATERIAL_ITEMS = {
  reinforce_1:  { name:'淬火石 x1',  give:{ reinforceStones:1 } },
  reinforce_10: { name:'淬火石 x10', give:{ reinforceStones:10 } },
  refine_1:     { name:'符文石 x1',  give:{ refinementStones:1 } },
  refine_10:    { name:'符文石 x10', give:{ refinementStones:10 } },
  pet_essence:  { name:'焰兽精华',   give:{ petEssence:100 } },
  pet_ticket:   { name:'宠物召唤券', give:{ petSummon:true } },
  pill_frag_health:  { name:'回灵丹碎片', give:{ pillFragment:'spirit_recovery' } },
  pill_frag_attack:  { name:'雷灵丹碎片', give:{ pillFragment:'thunder_power' } },
  pill_frag_defense: { name:'清心丹碎片', give:{ pillFragment:'mind_clarity' } },
  pill_frag_speed:   { name:'聚灵丹碎片', give:{ pillFragment:'spirit_gathering' } },
};

const PACK_ITEMS = {
  pack_starter: {
    price:10000, name:'新手礼包',
    contents:{ equips:[{quality:'rare',type:'weapon'},{quality:'rare',type:'body'}], reinforceStones:10, spirit:12500 }
  },
  pack_advanced: {
    price:50000, name:'进阶礼包',
    contents:{ equips:[{quality:'epic',type:'weapon'},{quality:'epic',type:'body'}], refinementStones:20, cultivationMultiplier:3000 }
  },
  pack_supreme: {
    price:200000, name:'至尊礼包',
    contents:{ equips:['weapon','head','body','legs','feet','shoulder','hands','wrist','necklace','ring1','ring2','belt','artifact'].map(t=>({quality:'legendary',type:t})), reinforceStones:50, refinementStones:30 }
  },
  pack_mythic: {
    price:500000, name:'仙品礼包',
    contents:{ equips:[{quality:'mythic',type:'weapon'},{quality:'mythic',type:'body'},{quality:'mythic',type:'artifact'}], levelups:10 }
  },
};

const HERB_ITEMS = {
  spirit_grass:        { name:'灵精草', baseValue:10 },
  cloud_flower:        { name:'云雾花', baseValue:15 },
  thunder_root:        { name:'雷击根', baseValue:25 },
  dragon_breath_herb:  { name:'龙息草', baseValue:40 },
  immortal_jade_grass: { name:'仙玉草', baseValue:60 },
  dark_yin_grass:      { name:'玄阴草', baseValue:30 },
  nine_leaf_lingzhi:   { name:'九叶灵芝', baseValue:45 },
  purple_ginseng:      { name:'紫金参', baseValue:50 },
  frost_lotus:         { name:'寒霜莲', baseValue:55 },
  fire_heart_flower:   { name:'火心花', baseValue:35 },
  moonlight_orchid:    { name:'月华兰', baseValue:70 },
  sun_essence_flower:  { name:'日精花', baseValue:75 },
  five_elements_grass: { name:'五行草', baseValue:80 },
  phoenix_feather_herb:{ name:'凤羽草', baseValue:85 },
  celestial_dew_grass: { name:'天露草', baseValue:90 },
};

const HERB_QUALITY_MULT = { common:1, uncommon:1.5, rare:2, epic:3, legendary:5 };

const FORMULA_ITEMS = {
  spirit_gathering:      { name:'聚灵丹方', grade:'一品', price:5000 },
  cultivation_boost:     { name:'聚气丹方', grade:'二品', price:10000 },
  spirit_recovery:       { name:'回灵丹方', grade:'二品', price:10000 },
  thunder_power:         { name:'雷灵丹方', grade:'三品', price:20000 },
  essence_condensation:  { name:'凝元丹方', grade:'三品', price:20000 },
  mind_clarity:          { name:'清心丹方', grade:'三品', price:20000 },
  immortal_essence:      { name:'仙灵丹方', grade:'四品', price:40000 },
  fire_essence:          { name:'火元丹方', grade:'四品', price:40000 },
  five_elements_pill:    { name:'五行丹方', grade:'五品', price:80000 },
  celestial_essence_pill:{ name:'天元丹方', grade:'六品', price:150000 },
  sun_moon_pill:         { name:'日月丹方', grade:'七品', price:300000 },
  phoenix_rebirth_pill:  { name:'涅槃丹方', grade:'八品', price:500000 },
};

const BUFF_ITEMS = {
  double_crystal: { price:30000, name:'焰晶双倍卡', buffKey:'doubleCrystal', duration:86400000 },
  cultivation_boost: { price:20000, name:'修炼加速卡', buffKey:'cultivationBoost', duration:86400000 },
  lucky_charm: { price:10000, name:'幸运符', buffKey:'luckyCharm', duration:86400000 },
};

function getRealmNameServer(level) {
  const realms = ['燃火期','炼气期','筑基期','金丹期','元婴期','化神期','合体期','大乘期','渡劫期','飞升期'];
  const layers = ['一层','二层','三层','四层','五层','六层','七层','八层','九层','十层'];
  const realmIndex = Math.min(Math.floor((level - 1) / 10), realms.length - 1);
  const layerIndex = (level - 1) % 10;
  return { name: realms[realmIndex] + layers[layerIndex], maxCultivation: 100 + level * 50 };
}

function applyLevelUp(gameData, level, times) {
  if (!gameData.baseAttributes) gameData.baseAttributes = { attack:10, health:100, defense:5, speed:10 };
  for (let j = 0; j < times; j++) {
    const newLevel = (gameData.level || level) + 1;
    gameData.level = newLevel;
    const realmInfo = getRealmNameServer(newLevel);
    gameData.realm = realmInfo.name;
    gameData.maxCultivation = realmInfo.maxCultivation;
    gameData.cultivation = 0;
    gameData.baseAttributes.attack += 8 + Math.floor(newLevel * 2.5);
    gameData.baseAttributes.health += 80 + Math.floor(newLevel * 25);
    gameData.baseAttributes.defense += 5 + Math.floor(newLevel * 2);
    gameData.baseAttributes.speed += 3 + Math.floor(newLevel * 1);
    gameData.spirit = (gameData.spirit || 0) + 200 * newLevel + 500;
    gameData.spiritRate = (gameData.spiritRate || 1) * 1.2;
  }
}

// 获取本周一 0:00 的时间戳
function getWeekStart() {
  const now = new Date();
  const day = now.getDay(); // 0 = Sunday, 1 = Monday
  const diff = now.getDate() - day + (day === 0 ? -6 : 1); // adjust when day is Sunday
  const monday = new Date(now.setDate(diff));
  monday.setHours(0, 0, 0, 0);
  return monday.getTime();
}

export default function(pool, auth) {

  // GET /list - 商品列表
  router.get('/list', (req, res) => {
    const config = getConfig();
    const materialPrices = config?.shop_material_prices || DEFAULT_MATERIAL_PRICES;
    
    const items = {
      equipment: Object.entries(EQUIP_PRICES).map(([q, p]) => ({
        category: 'equipment', id: 'equip_' + q, name: q + '品质随机装备',
        quality: q, price: p, description: '随机生成一件' + q + '品质装备'
      })),
      pills: Object.entries(PILL_ITEMS).map(([id, item]) => ({
        category: 'pill', id, name: item.name, price: item.price,
        effect: item.effect, description: item.name
      })),
      materials: Object.entries(MATERIAL_ITEMS).map(([id, item]) => ({
        category: 'material', id, name: item.name,
        price: materialPrices[id] || DEFAULT_MATERIAL_PRICES[id] || 1000,
        description: item.name
      })),
      packs: Object.entries(PACK_ITEMS).map(([id, item]) => ({
        category: 'pack', id, name: item.name, price: item.price,
        description: item.name
      })),
      buffs: Object.entries(BUFF_ITEMS).map(([id, item]) => ({
        category: 'buff', id, name: item.name, price: item.price,
        duration: item.duration, description: item.name
      })),
      herbs: Object.entries(HERB_ITEMS).map(([id, item]) => ({
        category: 'herb', id, name: item.name, baseValue: item.baseValue
      })),
      formulas: Object.entries(FORMULA_ITEMS).map(([id, item]) => ({
        category: 'formula', id, name: item.name, price: item.price,
        grade: item.grade
      }))
    };
    res.json({ ok: true, items });
  });

    router.post('/buy-equip', auth, async (req, res) => {
    try {
      console.log("[buy-equip] body:", JSON.stringify(req.body), "wallet:", req.user?.wallet);
      const { quality, equipType } = req.body;
      const wallet = req.user.wallet;
      
      // 读取限购配置
      const shopLimits = await getConfig('shop_limits') || { mythic_equip_enabled: false, legendary_equip_per_week: 1 };
      
      if (!EQUIP_PRICES[quality]) { console.log('[buy-equip] invalid quality:', quality); return res.status(400).json({ error: '无效品质' }); };
      if (!equipmentTypes[equipType]) { console.log('[buy-equip] invalid equipType:', equipType); return res.status(400).json({ error: '无效装备类型' }); };
      
      // 检查仙品装备是否启用
      if (quality === 'mythic' && shopLimits.mythic_equip_enabled === false) {
        return res.status(400).json({ error: '仙品装备已下架' });
      }
      
      const price = EQUIP_PRICES[quality];
      const playerResult = await pool.query('SELECT game_data, level FROM players WHERE wallet = $1', [wallet]);
      if (!playerResult.rows.length) return res.status(404).json({ error: '玩家不存在' });
      
      const player = playerResult.rows[0];
      const gameData = typeof player.game_data === 'string' ? JSON.parse(player.game_data) : (player.game_data || {});
      const level = player.level || gameData.level || 1;
      const stones = gameData.spiritStones || 0;
      
      // 检查极品装备每周限购
      if (quality === 'legendary') {
        const currentWeekStart = getWeekStart();
        const shopWeeklyPurchases = gameData.shopWeeklyPurchases || {};
        const legendaryData = shopWeeklyPurchases.legendary || { count: 0, weekStart: 0 };
        
        // 检查是否是同一周
        if (legendaryData.weekStart !== currentWeekStart) {
          // 新的一周，重置计数
          legendaryData.count = 0;
          legendaryData.weekStart = currentWeekStart;
        }
        
        const limit = shopLimits.legendary_equip_per_week || 1;
        if (legendaryData.count >= limit) {
          return res.status(400).json({ error: `极品装备每周限购${limit}件，本周已达上限` });
        }
        
        // 增加购买计数
        legendaryData.count++;
        shopWeeklyPurchases.legendary = legendaryData;
        gameData.shopWeeklyPurchases = shopWeeklyPurchases;
      }
      
      if (stones < price) return res.status(400).json({ error: '焰晶不足' });
      const capCheck = global.__checkStorageCapacity(gameData, 'equip');
      if (!capCheck.hasSpace) return res.status(400).json({ error: `装备仓库已满 (${capCheck.current}/${capCheck.limit})，请先清理或扩容` });
      const equip = generateEquipment(level, equipType, quality);
      equip.level = level;
      equip.requiredRealm = level;
      equip.id = Date.now() + Math.random();
      gameData.spiritStones = stones - price;
      if (!gameData.items) gameData.items = [];
      gameData.items.push(equip);
      await pool.query('UPDATE players SET game_data = $1, spirit_stones = $2 WHERE wallet = $3',
        [JSON.stringify(gameData), gameData.spiritStones, wallet]);
      res.json({ success: true, equip, spiritStones: gameData.spiritStones });
    } catch (e) { res.status(500).json({ error: e.message }); }
  });

  router.post('/buy-pill', auth, async (req, res) => {
    try {
      const { pillId, count = 1 } = req.body;
      const wallet = req.user.wallet;
      const pill = PILL_ITEMS[pillId];
      if (!pill) return res.status(400).json({ error: '丹药不存在' });
      if (count < 1 || count > 99) return res.status(400).json({ error: '数量无效' });
      const totalPrice = pill.price * count;
      const playerResult = await pool.query('SELECT game_data, level FROM players WHERE wallet = $1', [wallet]);
      if (!playerResult.rows.length) return res.status(404).json({ error: '玩家不存在' });
      const player = playerResult.rows[0];
      const gameData = typeof player.game_data === 'string' ? JSON.parse(player.game_data) : (player.game_data || {});
      const level = player.level || gameData.level || 1;
      const stones = gameData.spiritStones || 0;
      if (stones < totalPrice) return res.status(400).json({ error: '焰晶不足' });
      gameData.spiritStones = stones - totalPrice;
      let resultMsg = '';
      if (pill.effect === 'spirit') {
        gameData.spirit = (gameData.spirit || 0) + pill.value * count;
        resultMsg = '灵力 +' + (pill.value * count);
      } else if (pill.effect === 'cultivation') {
        const gain = level * pill.multiplier * count;
        gameData.cultivation = (gameData.cultivation || 0) + gain;
        resultMsg = '修为 +' + gain;
      } else if (pill.effect === 'levelup') {
        applyLevelUp(gameData, level, pill.levels * count);
        resultMsg = '升' + (pill.levels * count) + '级';
      } else if (pill.effect === 'attr') {
        if (!gameData.baseAttributes) gameData.baseAttributes = { attack:10, health:100, defense:5, speed:10 };
        gameData.baseAttributes[pill.stat] = (gameData.baseAttributes[pill.stat] || 0) + pill.value * count;
        resultMsg = pill.name + ' x' + count;
      }
      const newLevel = gameData.level || level;
      await pool.query('UPDATE players SET game_data = $1, spirit_stones = $2, level = $3, realm = $4 WHERE wallet = $5',
        [JSON.stringify(gameData), gameData.spiritStones, newLevel, gameData.realm || '燃火期一层', wallet]);
      res.json({ success: true, spiritStones: gameData.spiritStones, message: resultMsg, gameData });
    } catch (e) { res.status(500).json({ error: e.message }); }
  });

  router.post('/buy-material', auth, async (req, res) => {
    try {
      const { itemId, count = 1 } = req.body;
      const wallet = req.user.wallet;
      const item = MATERIAL_ITEMS[itemId];
      if (!item) return res.status(400).json({ error: '商品不存在' });
      if (count < 1 || count > 99) return res.status(400).json({ error: '数量无效' });
      
      // 从配置读取材料价格
      const materialPrices = await getConfig('material_prices') || {
        reinforce_stone: 1000,
        reinforce_stone_10: 9000,
        refine_stone: 1500,
        refine_stone_10: 13500
      };
      
      // 计算价格
      let unitPrice;
      switch(itemId) {
        case 'reinforce_1':
          unitPrice = materialPrices.reinforce_stone || DEFAULT_MATERIAL_PRICES.reinforce_1;
          break;
        case 'reinforce_10':
          unitPrice = materialPrices.reinforce_stone_10 || DEFAULT_MATERIAL_PRICES.reinforce_10;
          break;
        case 'refine_1':
          unitPrice = materialPrices.refine_stone || DEFAULT_MATERIAL_PRICES.refine_1;
          break;
        case 'refine_10':
          unitPrice = materialPrices.refine_stone_10 || DEFAULT_MATERIAL_PRICES.refine_10;
          break;
        default:
          unitPrice = DEFAULT_MATERIAL_PRICES[itemId] || 1000;
      }
      
      const totalPrice = unitPrice * count;
      const playerResult = await pool.query('SELECT game_data FROM players WHERE wallet = $1', [wallet]);
      if (!playerResult.rows.length) return res.status(404).json({ error: '玩家不存在' });
      const player = playerResult.rows[0];
      const gameData = typeof player.game_data === 'string' ? JSON.parse(player.game_data) : (player.game_data || {});
      const stones = gameData.spiritStones || 0;
      if (stones < totalPrice) return res.status(400).json({ error: '焰晶不足' });
      gameData.spiritStones = stones - totalPrice;
      const result = { reinforceStones:0, refinementStones:0, petEssence:0, pillFragments:{}, pets:[] };
      for (let i = 0; i < count; i++) {
        const give = item.give;
        if (give.reinforceStones) { gameData.reinforceStones = (gameData.reinforceStones||0) + give.reinforceStones; result.reinforceStones += give.reinforceStones; }
        if (give.refinementStones) { gameData.refinementStones = (gameData.refinementStones||0) + give.refinementStones; result.refinementStones += give.refinementStones; }
        if (give.petEssence) { gameData.petEssence = (gameData.petEssence||0) + give.petEssence; result.petEssence += give.petEssence; }
        if (give.pillFragment) {
          if (!gameData.pillFragments) gameData.pillFragments = {};
          gameData.pillFragments[give.pillFragment] = (gameData.pillFragments[give.pillFragment]||0) + 1;
          result.pillFragments[give.pillFragment] = (result.pillFragments[give.pillFragment]||0) + 1;
        }
        if (give.petSummon) {
          const pet = generatePet();
          pet.id = Date.now() + Math.random();
          if (!gameData.items) gameData.items = [];
          const petCap = global.__checkStorageCapacity(gameData, 'pet');
          if (!petCap.hasSpace) return res.status(400).json({ error: `焰兽仓库已满 (${petCap.current}/${petCap.limit})，请先清理或扩容` });
          gameData.items.push({ ...pet, type: 'pet' });
          result.pets.push(pet);
        }
      }
      await pool.query('UPDATE players SET game_data = $1, spirit_stones = $2 WHERE wallet = $3',
        [JSON.stringify(gameData), gameData.spiritStones, wallet]);
      res.json({ success: true, spiritStones: gameData.spiritStones, items: result });
    } catch (e) { res.status(500).json({ error: e.message }); }
  });

  router.post('/buy-pack', auth, async (req, res) => {
    try {
      const { packId } = req.body;
      const wallet = req.user.wallet;
      const pack = PACK_ITEMS[packId];
      if (!pack) return res.status(400).json({ error: '礼包不存在' });
      const playerResult = await pool.query('SELECT game_data, level FROM players WHERE wallet = $1', [wallet]);
      if (!playerResult.rows.length) return res.status(404).json({ error: '玩家不存在' });
      const player = playerResult.rows[0];
      const gameData = typeof player.game_data === 'string' ? JSON.parse(player.game_data) : (player.game_data || {});
      const level = player.level || gameData.level || 1;
      const stones = gameData.spiritStones || 0;
      if (stones < pack.price) return res.status(400).json({ error: '焰晶不足' });
      if (!gameData.purchasedPacks) gameData.purchasedPacks = [];
      if (gameData.purchasedPacks.includes(packId)) return res.status(400).json({ error: '该礼包已购买过' });
      gameData.spiritStones = stones - pack.price;
      gameData.purchasedPacks.push(packId);
      if (!gameData.items) gameData.items = [];
      const contents = pack.contents;
      const generatedEquips = [];
      if (contents.equips) {
        for (const eq of contents.equips) {
          const equip = generateEquipment(level, eq.type, eq.quality);
          equip.level = level; equip.requiredRealm = level; equip.id = Date.now() + Math.random();
          gameData.items.push(equip); generatedEquips.push(equip);
        }
      }
      if (contents.reinforceStones) gameData.reinforceStones = (gameData.reinforceStones||0) + contents.reinforceStones;
      if (contents.refinementStones) gameData.refinementStones = (gameData.refinementStones||0) + contents.refinementStones;
      if (contents.spirit) gameData.spirit = (gameData.spirit||0) + contents.spirit;
      if (contents.cultivationMultiplier) gameData.cultivation = (gameData.cultivation||0) + level * contents.cultivationMultiplier;
      if (contents.levelups) applyLevelUp(gameData, level, contents.levelups);
      const newLevel = gameData.level || level;
      await pool.query('UPDATE players SET game_data = $1, spirit_stones = $2, level = $3, realm = $4 WHERE wallet = $5',
        [JSON.stringify(gameData), gameData.spiritStones, newLevel, gameData.realm || '燃火期一层', wallet]);
      res.json({ success: true, spiritStones: gameData.spiritStones, equips: generatedEquips, gameData });
    } catch (e) { res.status(500).json({ error: e.message }); }
  });

  router.post('/buy-buff', auth, async (req, res) => {
    try {
      const { buffId } = req.body;
      const wallet = req.user.wallet;
      const buff = BUFF_ITEMS[buffId];
      if (!buff) return res.status(400).json({ error: '特权不存在' });
      const playerResult = await pool.query('SELECT game_data FROM players WHERE wallet = $1', [wallet]);
      if (!playerResult.rows.length) return res.status(404).json({ error: '玩家不存在' });
      const player = playerResult.rows[0];
      const gameData = typeof player.game_data === 'string' ? JSON.parse(player.game_data) : (player.game_data || {});
      const stones = gameData.spiritStones || 0;
      if (stones < buff.price) return res.status(400).json({ error: '焰晶不足' });
      gameData.spiritStones = stones - buff.price;
      if (!gameData.buffs) gameData.buffs = {};
      gameData.buffs[buff.buffKey] = Date.now() + buff.duration;
      await pool.query('UPDATE players SET game_data = $1, spirit_stones = $2 WHERE wallet = $3',
        [JSON.stringify(gameData), gameData.spiritStones, wallet]);
      res.json({ success: true, spiritStones: gameData.spiritStones, buffKey: buff.buffKey, expiresAt: gameData.buffs[buff.buffKey] });
    } catch (e) { res.status(500).json({ error: e.message }); }
  });

  router.post('/buy-herb', auth, async (req, res) => {
    try {
      const { herbId, quality, quantity = 1 } = req.body;
      const wallet = req.user.wallet;
      const herb = HERB_ITEMS[herbId];
      if (!herb) return res.status(400).json({ error: '焰草不存在' });
      const mult = HERB_QUALITY_MULT[quality];
      if (!mult) { console.log('[buy-equip] invalid quality:', quality); return res.status(400).json({ error: '无效品质' }); };
      if (quantity < 1 || quantity > 99) return res.status(400).json({ error: '数量无效' });
      const unitPrice = Math.floor(herb.baseValue * mult * 100);
      const totalPrice = unitPrice * quantity;
      const playerResult = await pool.query('SELECT game_data FROM players WHERE wallet = $1', [wallet]);
      if (!playerResult.rows.length) return res.status(404).json({ error: '玩家不存在' });
      const gameData = typeof playerResult.rows[0].game_data === 'string' ? JSON.parse(playerResult.rows[0].game_data) : (playerResult.rows[0].game_data || {});
      const stones = gameData.spiritStones || 0;
      if (stones < totalPrice) return res.status(400).json({ error: '焰晶不足' });
      gameData.spiritStones = stones - totalPrice;
      if (!gameData.herbs) gameData.herbs = [];
      for (let i = 0; i < quantity; i++) {
        gameData.herbs.push({
          id: herbId, herbId, herb_id: herbId,
          name: herb.name, quality,
          value: herb.baseValue * mult,
          obtainedAt: Date.now()
        });
      }
      await pool.query('UPDATE players SET game_data = $1, spirit_stones = $2 WHERE wallet = $3',
        [JSON.stringify(gameData), gameData.spiritStones, wallet]);
      res.json({ success: true, spiritStones: gameData.spiritStones, message: `获得 ${herb.name}(${quality}) x${quantity}` });
    } catch (e) { res.status(500).json({ error: e.message }); }
  });

  router.post('/buy-formula', auth, async (req, res) => {
    try {
      const { formulaId } = req.body;
      const wallet = req.user.wallet;
      const formula = FORMULA_ITEMS[formulaId];
      if (!formula) return res.status(400).json({ error: '焰方不存在' });
      const playerResult = await pool.query('SELECT game_data FROM players WHERE wallet = $1', [wallet]);
      if (!playerResult.rows.length) return res.status(404).json({ error: '玩家不存在' });
      const gameData = typeof playerResult.rows[0].game_data === 'string' ? JSON.parse(playerResult.rows[0].game_data) : (playerResult.rows[0].game_data || {});
      const stones = gameData.spiritStones || 0;
      if (stones < formula.price) return res.status(400).json({ error: '焰晶不足' });
      if (!gameData.pillRecipes) gameData.pillRecipes = [];
      if (gameData.pillRecipes.includes(formulaId)) return res.status(400).json({ error: '已拥有该焰方' });
      gameData.spiritStones = stones - formula.price;
      gameData.pillRecipes.push(formulaId);
      await pool.query('UPDATE players SET game_data = $1, spirit_stones = $2 WHERE wallet = $3',
        [JSON.stringify(gameData), gameData.spiritStones, wallet]);
      res.json({ success: true, spiritStones: gameData.spiritStones, message: `解锁焰方：${formula.name}` });
    } catch (e) { res.status(500).json({ error: e.message }); }
  });

  router.get('/purchased-packs', auth, async (req, res) => {
    try {
      const wallet = req.user.wallet;
      const playerResult = await pool.query('SELECT game_data FROM players WHERE wallet = $1', [wallet]);
      if (!playerResult.rows.length) return res.status(404).json({ error: '玩家不存在' });
      const gameData = typeof playerResult.rows[0].game_data === 'string' ? JSON.parse(playerResult.rows[0].game_data) : (playerResult.rows[0].game_data || {});
      res.json({ purchasedPacks: gameData.purchasedPacks || [], buffs: gameData.buffs || {} });
    } catch (e) { res.status(500).json({ error: e.message }); }
  });

  return router;
}
