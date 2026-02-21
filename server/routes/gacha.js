import { Router } from 'express'
import pool from '../db.js'
import { getConfig } from '../game-config.js'

const router = Router()

// VIP折扣配置
const VIP_DISCOUNTS = [1, 0.95, 0.9, 0.85, 0.8, 0.7]

// 装备品质配置
const equipmentQualities = {
  common: { name: '凡品', color: '#9e9e9e', statMod: 1.0, maxStatMod: 1.5 },
  uncommon: { name: '下品', color: '#4caf50', statMod: 1.2, maxStatMod: 2.0 },
  rare: { name: '中品', color: '#2196f3', statMod: 1.5, maxStatMod: 2.5 },
  epic: { name: '上品', color: '#9c27b0', statMod: 2.0, maxStatMod: 3.0 },
  legendary: { name: '极品', color: '#ff9800', statMod: 2.5, maxStatMod: 3.5 },
  mythic: { name: '仙品', color: '#e91e63', statMod: 3.0, maxStatMod: 4.0 }
}

// 装备基础概率（fallback）
const baseEquipProbabilities = {
  common: 0.5, uncommon: 0.3, rare: 0.12, epic: 0.05, legendary: 0.02, mythic: 0.01
}

// 装备类型配置
const equipmentTypes = {
  weapon: { name: '焰杖', slot: 'weapon', prefixes: ['九天', '太虚', '混沌', '玄天', '紫霄', '青冥', '赤炎', '幽冥'] },
  head: { name: '头部', slot: 'head', prefixes: ['天灵', '玄冥', '紫金', '青玉', '赤霞', '幽月', '星辰', '云霄'] },
  body: { name: '衣服', slot: 'body', prefixes: ['九霄', '太素', '混元', '玄阳', '紫薇', '青龙', '赤凤', '幽冥'] },
  legs: { name: '裤子', slot: 'legs', prefixes: ['天罡', '玄武', '紫电', '青云', '赤阳', '幽灵', '星光', '云雾'] },
  feet: { name: '鞋子', slot: 'feet', prefixes: ['天行', '玄风', '紫霞', '青莲', '赤焰', '幽影', '星步', '云踪'] },
  shoulder: { name: '肩甲', slot: 'shoulder', prefixes: ['天护', '玄甲', '紫雷', '青锋', '赤羽', '幽岚', '星芒', '云甲'] },
  hands: { name: '手套', slot: 'hands', prefixes: ['天罗', '玄玉', '紫晶', '青钢', '赤金', '幽银', '星铁', '云纹'] },
  wrist: { name: '护腕', slot: 'wrist', prefixes: ['天绝', '玄铁', '紫玉', '青石', '赤铜', '幽钢', '星晶', '云纱'] },
  necklace: { name: '焰心链', slot: 'necklace', prefixes: ['天珠', '玄圣', '紫灵', '青魂', '赤心', '幽魄', '星魂', '云珠'] },
  ring1: { name: '符文戒1', slot: 'ring1', prefixes: ['天命', '玄命', '紫命', '青命', '赤命', '幽命', '星命', '云命'] },
  ring2: { name: '符文戒2', slot: 'ring2', prefixes: ['天道', '玄道', '紫道', '青道', '赤道', '幽道', '星道', '云道'] },
  belt: { name: '腰带', slot: 'belt', prefixes: ['天系', '玄系', '紫系', '青系', '赤系', '幽系', '星系', '云系'] },
  artifact: { name: '焰器', slot: 'artifact', prefixes: ['天宝', '玄宝', '紫宝', '青宝', '赤宝', '幽宝', '星宝', '云宝'] }
}

// 装备基础属性范围
const equipmentBaseStats = {
  weapon: { attack: { name: '攻击', min: 10, max: 20 }, critRate: { name: '暴击率', min: 0.05, max: 0.1 }, critDamageBoost: { name: '暴击伤害', min: 0.1, max: 0.3 } },
  head: { defense: { name: '防御', min: 5, max: 10 }, health: { name: '生命', min: 50, max: 100 }, stunResist: { name: '抗眩晕', min: 0.05, max: 0.1 } },
  body: { defense: { name: '防御', min: 8, max: 15 }, health: { name: '生命', min: 80, max: 150 }, finalDamageReduce: { name: '最终减伤', min: 0.05, max: 0.1 } },
  legs: { defense: { name: '防御', min: 6, max: 12 }, speed: { name: '速度', min: 5, max: 10 }, dodgeRate: { name: '闪避率', min: 0.05, max: 0.1 } },
  feet: { defense: { name: '防御', min: 4, max: 8 }, speed: { name: '速度', min: 8, max: 15 }, dodgeRate: { name: '闪避率', min: 0.05, max: 0.1 } },
  shoulder: { defense: { name: '防御', min: 5, max: 10 }, health: { name: '生命', min: 40, max: 80 }, counterRate: { name: '反击率', min: 0.05, max: 0.1 } },
  hands: { attack: { name: '攻击', min: 5, max: 10 }, critRate: { name: '暴击率', min: 0.03, max: 0.08 }, comboRate: { name: '连击率', min: 0.05, max: 0.1 } },
  wrist: { defense: { name: '防御', min: 3, max: 8 }, counterRate: { name: '反击率', min: 0.05, max: 0.1 }, vampireRate: { name: '吸血率', min: 0.05, max: 0.1 } },
  necklace: { health: { name: '生命', min: 60, max: 120 }, healBoost: { name: '强化治疗', min: 0.1, max: 0.2 }, spiritRate: { name: '焰灵获取', min: 0.1, max: 0.2 } },
  ring1: { attack: { name: '攻击', min: 5, max: 10 }, critDamageBoost: { name: '暴击伤害', min: 0.1, max: 0.2 }, finalDamageBoost: { name: '最终增伤', min: 0.05, max: 0.1 } },
  ring2: { defense: { name: '防御', min: 5, max: 10 }, critDamageReduce: { name: '爆伤减免', min: 0.1, max: 0.2 }, resistanceBoost: { name: '抗性提升', min: 0.05, max: 0.1 } },
  belt: { health: { name: '生命', min: 40, max: 80 }, defense: { name: '防御', min: 4, max: 8 }, combatBoost: { name: '战斗属性', min: 0.05, max: 0.1 } },
  artifact: { attack: { name: '攻击力', min: 0.1, max: 0.3 }, critRate: { name: '暴击率', min: 0.1, max: 0.3 }, comboRate: { name: '连击率', min: 0.1, max: 0.3 } }
}

// 宠物品质配置（fallback）
const petRarities = {
  divine: { name: '神品', color: '#FF0000', probability: 0.002, essenceBonus: 50 },
  celestial: { name: '仙品', color: '#FFD700', probability: 0.0581, essenceBonus: 30 },
  mystic: { name: '玄品', color: '#9932CC', probability: 0.1601, essenceBonus: 20 },
  spiritual: { name: '灵品', color: '#1E90FF', probability: 0.2801, essenceBonus: 10 },
  mortal: { name: '凡品', color: '#32CD32', probability: 0.4997, essenceBonus: 5 }
}

// 宠物池
const petPool = {
  divine: [
    { name: '玄武', description: '北方守护神兽' }, { name: '白虎', description: '西方守护神兽' },
    { name: '朱雀', description: '南方守护神兽' }, { name: '青龙', description: '东方守护神兽' },
    { name: '应龙', description: '上古神龙，掌控风雨' }, { name: '麒麟', description: '祥瑞之兽，通晓万物' },
    { name: '饕餮', description: '贪婪之兽，吞噬万物，象征无尽的欲望' },
    { name: '穷奇', description: '邪恶之兽，背信弃义，象征混乱与背叛' },
    { name: '梼杌', description: '凶暴之兽，顽固不化，象征无法驯服的野性' },
    { name: '混沌', description: '无序之兽，无形无相，象征原始的混乱' }
  ],
  celestial: [
    { name: '囚牛', description: '龙之长子，喜好音乐，常立于琴头' },
    { name: '睚眦', description: '龙之次子，性格刚烈，嗜杀好斗，常刻于刀剑之上' },
    { name: '嘲风', description: '龙之三子，形似兽，喜好冒险，常立于殿角' },
    { name: '蒲牢', description: '龙之四子，形似龙而小，性好鸣，常铸于钟上' },
    { name: '狻犴', description: '龙之五子，形似狮子，喜静好坐，常立于香炉' },
    { name: '霸下', description: '龙之六子，形似龟，力大无穷，常背负石碑' },
    { name: '狴犴', description: '龙之七子，形似虎，明辨是非，常立于狱门' },
    { name: '负屃', description: '龙之八子，形似龙，雅好诗文，常盘于碑顶' },
    { name: '螭吻', description: '龙之九子，形似鱼，能吞火，常立于屋脊' }
  ],
  mystic: [
    { name: '火凤凰', description: '浴火重生的永恒之鸟' }, { name: '雷鹰', description: '雷电的猛禽' },
    { name: '冰狼', description: '冰原霸主' }, { name: '岩龟', description: '坚不可摧的守护者' }
  ],
  spiritual: [
    { name: '玄龟', description: '擅长防御的水系焰兽' }, { name: '风隼', description: '速度极快的飞行焰兽' },
    { name: '地甲', description: '坚固的大地守护者' }, { name: '云豹', description: '敏捷的猎手' }
  ],
  mortal: [
    { name: '灵猫', description: '敏捷的小型焰兽' }, { name: '幻蝶', description: '美丽的蝴蝶焰兽' },
    { name: '火鼠', description: '活泼的啮齿类焰兽' }, { name: '草兔', description: '温顺的兔类焰兽' }
  ]
}

// 装备出售价格
const sellPrices = { common: 1, uncommon: 2, rare: 3, epic: 4, legendary: 5, mythic: 6 }

// 背包容量配置
const storageConfig = {
  equip: { base: 100, perLevel: 20 },
  pet: { base: 30, perLevel: 5 }
}

// 获取活动效果
async function getEventEffects() {
  try {
    const result = await pool.query(
      "SELECT type, config FROM events WHERE active = TRUE AND starts_at <= NOW() AND ends_at > NOW()"
    )
    let gachaRateBoost = 1
    for (const evt of result.rows) {
      const cfg = evt.config || {}
      if (evt.type === 'gacha_rate_up') gachaRateBoost *= (cfg.rateBoost || 1.5)
    }
    return { gachaRateBoost }
  } catch {
    return { gachaRateBoost: 1 }
  }
}

// 获取VIP折扣
async function getVipDiscount(wallet) {
  try {
    const result = await pool.query('SELECT vip_level FROM players WHERE wallet = $1', [wallet])
    const vipLevel = result.rows[0]?.vip_level || 0
    return VIP_DISCOUNTS[Math.min(vipLevel, 5)]
  } catch {
    return 1
  }
}

// 心愿单加成计算
function getWishlistBonus(baseProb) {
  return Math.min(1.0, 0.2 / baseProb)
}

// 获取调整后的装备概率
async function getAdjustedEquipProbabilities(wishlistEnabled, wishEquipQuality, gachaRateBoost = 1) {
  // 从配置读取基础概率
  const configProbs = await getConfig('gacha_equip_probs')
  const probs = configProbs ? { ...configProbs } : { ...baseEquipProbabilities }
  
  // 活动加成
  if (gachaRateBoost > 1) {
    const rareKeys = ['rare', 'epic', 'legendary', 'mythic']
    let boosted = 0
    rareKeys.forEach(k => { 
      const old = probs[k] 
      probs[k] = Math.min(old * gachaRateBoost, 0.5) 
      boosted += probs[k] - old 
    })
    probs.common = Math.max(0.05, probs.common - boosted * 0.7)
    probs.uncommon = Math.max(0.05, probs.uncommon - boosted * 0.3)
  }
  
  // 心愿单加成
  if (wishlistEnabled && wishEquipQuality && probs[wishEquipQuality]) {
    const bonus = getWishlistBonus((await getConfig('gacha_equip_probs'))?.[wishEquipQuality] || baseEquipProbabilities[wishEquipQuality])
    probs[wishEquipQuality] *= 1 + bonus
    const totalOtherProb = Object.entries(probs)
      .filter(([q]) => q !== wishEquipQuality)
      .reduce((sum, [, prob]) => sum + prob, 0)
    const reductionFactor = (1 - probs[wishEquipQuality]) / totalOtherProb
    Object.keys(probs).forEach(q => { 
      if (q !== wishEquipQuality) probs[q] *= reductionFactor 
    })
  }
  
  return probs
}

// 获取调整后的宠物概率
async function getAdjustedPetProbabilities(wishlistEnabled, wishPetRarity, gachaRateBoost = 1) {
  // 从配置读取基础概率
  const configProbs = await getConfig('gacha_pet_probs')
  const probs = {}
  if (configProbs) {
    Object.keys(petRarities).forEach(rarity => { probs[rarity] = configProbs[rarity] || petRarities[rarity].probability })
  } else {
    Object.entries(petRarities).forEach(([rarity, config]) => { probs[rarity] = config.probability })
  }
  
  // 活动加成
  if (gachaRateBoost > 1) {
    const rareKeys = ['mystic', 'celestial', 'divine']
    let boosted = 0
    rareKeys.forEach(k => { 
      if (probs[k]) { 
        const old = probs[k] 
        probs[k] = Math.min(old * gachaRateBoost, 0.4) 
        boosted += probs[k] - old 
      } 
    })
    if (probs.mortal) probs.mortal = Math.max(0.05, probs.mortal - boosted * 0.6)
    if (probs.spiritual) probs.spiritual = Math.max(0.05, probs.spiritual - boosted * 0.4)
  }
  
  // 心愿单加成
  if (wishlistEnabled && wishPetRarity && probs[wishPetRarity]) {
    const baseProb = (await getConfig('gacha_pet_probs'))?.[wishPetRarity] || petRarities[wishPetRarity].probability
    const bonus = getWishlistBonus(baseProb)
    probs[wishPetRarity] *= 1 + bonus
    const totalOtherProb = Object.entries(probs)
      .filter(([r]) => r !== wishPetRarity)
      .reduce((sum, [, prob]) => sum + prob, 0)
    const reductionFactor = (1 - probs[wishPetRarity]) / totalOtherProb
    Object.keys(probs).forEach(r => { 
      if (r !== wishPetRarity) probs[r] *= reductionFactor 
    })
  }
  
  return probs
}

// 统计全服神话装备数量（按槽位）
async function getGlobalMythicEquipCount(slot) {
  try {
    const result = await pool.query('SELECT game_data FROM players')
    let count = 0
    for (const row of result.rows) {
      if (!row.game_data) continue
      const gameData = typeof row.game_data === 'string' ? JSON.parse(row.game_data) : row.game_data
      const items = gameData.items || []
      count += items.filter(item => item.quality === 'mythic' && (item.slot === slot || item.type === slot)).length
    }
    return count
  } catch (e) {
    console.error('Get global mythic count error:', e)
    return 0
  }
}

// 统计全服神品焰兽数量
async function getGlobalDivinePetCount() {
  try {
    const result = await pool.query('SELECT game_data FROM players')
    let count = 0
    for (const row of result.rows) {
      if (!row.game_data) continue
      const gameData = typeof row.game_data === 'string' ? JSON.parse(row.game_data) : row.game_data
      const items = gameData.items || []
      count += items.filter(item => item.rarity === 'divine' && item.type === 'pet').length
    }
    return count
  } catch (e) {
    console.error('Get global divine pet count error:', e)
    return 0
  }
}

// 生成装备名称
function generateEquipmentName(type, quality) {
  const typeInfo = equipmentTypes[type]
  const prefix = typeInfo.prefixes[Math.floor(Math.random() * typeInfo.prefixes.length)]
  const suffixes = ['', '·真', '·极', '·道', '·天', '·仙', '·圣', '·神']
  const suffixIndex = quality === 'mythic' ? 7 : quality === 'legendary' ? 6 : quality === 'epic' ? 5 : quality === 'rare' ? 4 : quality === 'uncommon' ? 3 : 0
  const suffix = suffixes[suffixIndex]
  return `${prefix}${typeInfo.name}${suffix}`
}

// 生成装备
function generateEquipment(level, type = null, quality = null) {
  if (!type) {
    const types = Object.keys(equipmentTypes)
    type = types[Math.floor(Math.random() * types.length)]
  }
  if (!quality) {
    const roll = Math.random()
    if (roll < 0.35) quality = 'common'
    else if (roll < 0.65) quality = 'uncommon'
    else if (roll < 0.82) quality = 'rare'
    else if (roll < 0.93) quality = 'epic'
    else if (roll < 0.98) quality = 'legendary'
    else quality = 'mythic'
  }
  
  const minLevel = Math.max(1, level - 10)
  const randomLevel = Math.floor(Math.random() * (level - minLevel + 1)) + minLevel
  const baseStats = {}
  const qualityMod = equipmentQualities[quality].statMod
  const levelMod = 1 + randomLevel * 0.1
  
  Object.entries(equipmentBaseStats[type]).forEach(([stat, config]) => {
    const base = config.min + Math.random() * (config.max - config.min)
    const value = base * qualityMod * levelMod
    if (['critRate', 'critDamageBoost', 'dodgeRate', 'vampireRate', 'finalDamageBoost', 'finalDamageReduce', 'comboRate', 'counterRate', 'stunRate', 'healBoost', 'spiritRate', 'combatBoost', 'resistanceBoost', 'critDamageReduce', 'stunResist', 'vampireResist', 'dodgeResist', 'comboResist', 'counterResist', 'critResist', 'cultivationRate'].includes(stat)) {
      baseStats[stat] = Math.round(value * 100) / 100
    } else {
      baseStats[stat] = Math.round(value)
    }
  })
  
  return {
    id: Date.now() + Math.random(),
    name: generateEquipmentName(type, quality),
    type, slot: type, quality, level: randomLevel, requiredRealm: randomLevel,
    stats: baseStats, equipType: type, qualityInfo: equipmentQualities[quality]
  }
}

// 获取品质倍率
function getRarityMultiplier(rarity) {
  const multipliers = {
    divine: { base: 5, percent: 2 }, celestial: { base: 4, percent: 1.8 },
    mystic: { base: 3, percent: 1.6 }, spiritual: { base: 2, percent: 1.4 },
    mortal: { base: 1, percent: 1 }
  }
  return multipliers[rarity] || multipliers.mortal
}

// 生成随机值
function generateRandomValue(min, max, isPercentage = false) {
  const value = min + Math.random() * (max - min)
  return isPercentage ? Math.min(1, Math.round(value * 100) / 100) : Math.round(value)
}

// 生成宠物战斗属性
function combatAttributes(rarity) {
  const multiplier = getRarityMultiplier(rarity)
  const baseStats = {
    attack: { min: 10, max: 15, useBase: true }, health: { min: 100, max: 120, useBase: true },
    defense: { min: 5, max: 8, useBase: true }, speed: { min: 10, max: 15, useBase: true, multiplier: 0.6 },
    critRate: { min: 0.05, max: 0.1, isPercentage: true }, comboRate: { min: 0.05, max: 0.1, isPercentage: true },
    counterRate: { min: 0.05, max: 0.1, isPercentage: true }, stunRate: { min: 0.05, max: 0.1, isPercentage: true },
    dodgeRate: { min: 0.05, max: 0.1, isPercentage: true }, vampireRate: { min: 0.05, max: 0.1, isPercentage: true },
    critResist: { min: 0.05, max: 0.1, isPercentage: true }, comboResist: { min: 0.05, max: 0.1, isPercentage: true },
    counterResist: { min: 0.05, max: 0.1, isPercentage: true }, stunResist: { min: 0.05, max: 0.1, isPercentage: true },
    dodgeResist: { min: 0.05, max: 0.1, isPercentage: true }, vampireResist: { min: 0.05, max: 0.1, isPercentage: true },
    healBoost: { min: 0.05, max: 0.1, isPercentage: true }, critDamageBoost: { min: 0.05, max: 0.1, isPercentage: true },
    critDamageReduce: { min: 0.05, max: 0.1, isPercentage: true }, finalDamageBoost: { min: 0.05, max: 0.1, isPercentage: true },
    finalDamageReduce: { min: 0.05, max: 0.1, isPercentage: true }, combatBoost: { min: 0.05, max: 0.1, isPercentage: true },
    resistanceBoost: { min: 0.05, max: 0.1, isPercentage: true }
  }
  const attributes = {}
  Object.entries(baseStats).forEach(([key, config]) => {
    if (config.isPercentage) {
      attributes[key] = generateRandomValue(config.min * multiplier.percent, config.max * multiplier.percent, true)
    } else {
      const baseMultiplier = config.useBase ? multiplier.base : multiplier.percent
      const finalMultiplier = config.multiplier ? baseMultiplier * config.multiplier : baseMultiplier
      attributes[key] = generateRandomValue(config.min * finalMultiplier, config.max * finalMultiplier)
    }
  })
  return attributes
}

// 生成宠物
function generatePet(rarity = null) {
  const probs = {}
  Object.entries(petRarities).forEach(([r, config]) => { probs[r] = config.probability })
  
  if (!rarity) {
    const random = Math.random()
    let accumulatedProb = 0
    for (const [r, probability] of Object.entries(probs)) {
      accumulatedProb += probability
      if (random <= accumulatedProb) {
        rarity = r
        break
      }
    }
    if (!rarity) rarity = 'mortal'
  }
  
  const pool = petPool[rarity]
  const pet = pool[Math.floor(Math.random() * pool.length)]
  const upgradeItemCount = { divine: 5, celestial: 4, mystic: 3, spiritual: 2, mortal: 1 }
  
  return {
    ...pet, rarity, type: 'pet',
    quality: { strength: Math.floor(Math.random() * 10) + 1, agility: Math.floor(Math.random() * 10) + 1, intelligence: Math.floor(Math.random() * 10) + 1, constitution: Math.floor(Math.random() * 10) + 1 },
    power: 0, experience: 0, maxExperience: 100, level: 1, star: 0,
    upgradeItems: upgradeItemCount[rarity] || 1, combatAttributes: combatAttributes(rarity)
  }
}

// 抽取单个装备（带保底和限量检查）
async function drawSingleEquip(level, wishlistEnabled, wishEquipQuality, gachaRateBoost, pity) {
  const probs = await getAdjustedEquipProbabilities(wishlistEnabled, wishEquipQuality, gachaRateBoost)
  const gachaPity = await getConfig('gacha_pity')
  
  // 保底检查
  let forcedQuality = null
  if (gachaPity) {
    if (pity.equipCount >= gachaPity.mythic_guarantee) {
      forcedQuality = 'mythic' // 保底神话无视限量
    } else if (pity.equipCount >= gachaPity.legendary_guarantee) {
      forcedQuality = 'legendary'
    } else if (pity.equipCount >= gachaPity.epic_guarantee) {
      forcedQuality = 'epic'
    }
  }
  
  let quality = forcedQuality
  
  if (!quality) {
    const random = Math.random()
    let accumulatedProb = 0
    
    for (const [q, probability] of Object.entries(probs)) {
      accumulatedProb += probability
      if (random <= accumulatedProb) {
        quality = q
        break
      }
    }
  }
  
  quality = quality || 'common'
  
  // 先确定槽位
  const types = Object.keys(equipmentTypes)
  const type = types[Math.floor(Math.random() * types.length)]
  
  // 限量检查：mythic装备
  if (quality === 'mythic') {
    const gachaLimits = await getConfig('gacha_limits')
    const limit = gachaLimits?.mythic_per_slot || 50
    const currentCount = await getGlobalMythicEquipCount(type)
    
    // 如果超限且不是保底触发，降级为legendary
    if (currentCount >= limit && forcedQuality !== 'mythic') {
      quality = 'legendary'
    }
  }
  
  return { item: generateEquipment(level, type, quality), quality }
}

// 抽取单个宠物（带保底和限量检查）
async function drawSinglePet(wishlistEnabled, wishPetRarity, gachaRateBoost, pity) {
  const probs = await getAdjustedPetProbabilities(wishlistEnabled, wishPetRarity, gachaRateBoost)
  const gachaPity = await getConfig('gacha_pity')
  
  // 保底检查
  let forcedRarity = null
  if (gachaPity) {
    if (pity.petCount >= gachaPity.pet_celestial_guarantee) {
      forcedRarity = 'celestial'
    } else if (pity.petCount >= gachaPity.pet_mystic_guarantee) {
      forcedRarity = 'mystic'
    }
  }
  
  let rarity = forcedRarity
  
  if (!rarity) {
    const random = Math.random()
    let accumulatedProb = 0
    
    for (const [r, probability] of Object.entries(probs)) {
      accumulatedProb += probability
      if (random <= accumulatedProb) {
        rarity = r
        break
      }
    }
  }
  
  rarity = rarity || 'mortal'
  
  // 限量检查：divine宠物
  if (rarity === 'divine') {
    const gachaLimits = await getConfig('gacha_limits')
    const limit = gachaLimits?.divine_pets || 20
    const currentCount = await getGlobalDivinePetCount()
    
    // divine没有保底，超限降级
    if (currentCount >= limit) {
      rarity = 'celestial'
    }
  }
  
  return { item: generatePet(rarity), rarity }
}

// 从综合池抽取
async function drawFromAllPool(level, wishlistEnabled, wishEquipQuality, wishPetRarity, gachaRateBoost, pity) {
  const random = Math.random()
  if (random < 0.5) {
    const { item, quality } = await drawSingleEquip(level, wishlistEnabled, wishEquipQuality, gachaRateBoost, pity)
    item.category = 'equipment'
    return { item, type: 'equipment', quality }
  } else {
    const { item, rarity } = await drawSinglePet(wishlistEnabled, wishPetRarity, gachaRateBoost, pity)
    return { item: { ...item, type: 'pet' }, type: 'pet', rarity }
  }
}

// 认证中间件
function auth(req, res, next) {
  const header = req.headers.authorization
  if (!header) return res.status(401).json({ error: '未登录' })
  const token = header.replace('Bearer ', '')
  
  import('jsonwebtoken').then(jwt => {
    const JWT_SECRET = process.env.JWT_SECRET || 'xiuxian_jwt_secret_2026'
    const OLD_JWT_SECRET = process.env.JWT_SECRET || 'xiuxian_secret_2026'
    
    try {
      const decoded = jwt.default.verify(token, JWT_SECRET)
      req.user = { wallet: decoded.walletAddress || decoded.wallet }
      return next()
    } catch {}
    
    try {
      const decoded = jwt.default.verify(token, OLD_JWT_SECRET)
      req.user = { wallet: decoded.wallet || decoded.id }
      return next()
    } catch {}
    
    return res.status(401).json({ error: 'token无效或已过期' })
  })
}

// GET /api/gacha/probabilities - 获取当前概率
router.get('/probabilities', async (req, res) => {
  try {
    const { type = 'all', wishlistEnabled = 'false', wishEquipQuality, wishPetRarity } = req.query
    const enabled = wishlistEnabled === 'true'
    const { gachaRateBoost } = await getEventEffects()
    
    let response = {
      gachaRateBoost,
      wishlistEnabled: enabled
    }
    
    if (type === 'equipment' || type === 'all') {
      response.equipment = await getAdjustedEquipProbabilities(enabled, wishEquipQuality, gachaRateBoost)
    }
    
    if (type === 'pet' || type === 'all') {
      response.pet = await getAdjustedPetProbabilities(enabled, wishPetRarity, gachaRateBoost)
    }
    
    if (type === 'all') {
      // 综合池概率（50%装备，50%宠物）
      const equipProbs = response.equipment
      const adjustedEquipProbs = {}
      Object.entries(equipProbs).forEach(([quality, prob]) => { adjustedEquipProbs[quality] = prob * 0.5 })
      
      const petProbs = response.pet
      const adjustedPetProbs = {}
      Object.entries(petProbs).forEach(([rarity, prob]) => { adjustedPetProbs[rarity] = prob * 0.5 })
      
      response.equipment = adjustedEquipProbs
      response.pet = adjustedPetProbs
    }
    
    res.json(response)
  } catch (e) {
    res.status(500).json({ error: e.message })
  }
})

// POST /api/gacha/draw - 抽卡主接口
router.post('/draw', auth, async (req, res) => {
  try {
    const wallet = req.user.wallet
    const { count = 1, type = 'all', wishlistEnabled = false, wishEquipQuality, wishPetRarity } = req.body
    
    if (![1, 10, 50, 100].includes(count)) {
      return res.status(400).json({ error: '无效的抽卡次数' })
    }
    
    // 获取玩家数据
    const playerResult = await pool.query('SELECT game_data, level, vip_level FROM players WHERE wallet = $1', [wallet])
    if (!playerResult.rows.length) {
      return res.status(404).json({ error: '玩家不存在' })
    }
    
    const player = playerResult.rows[0]
    const gameData = typeof player.game_data === 'string' ? JSON.parse(player.game_data) : (player.game_data || {})
    const level = player.level || gameData.level || 1
    const vipLevel = player.vip_level || 0
    
    // 获取活动效果
    let { gachaRateBoost } = await getEventEffects()
    
    // 幸运符buff：提升稀有品质概率 (等效 gachaRateBoost +30%)
    const buffs = gameData.buffs || {}
    if (buffs.luckyCharm && buffs.luckyCharm > Date.now()) {
      gachaRateBoost = (gachaRateBoost || 1) * 1.3
    }
    
    // 从配置获取费用
    const gachaCost = await getConfig('gacha_cost')
    const normalCost = gachaCost?.normal || 100
    const wishlistCost = gachaCost?.wishlist || 200
    
    // 计算费用
    const baseCost = wishlistEnabled ? count * wishlistCost : count * normalCost
    const vipDiscount = VIP_DISCOUNTS[Math.min(vipLevel, 5)]
    const cost = Math.floor(baseCost * vipDiscount)
    
    // 检查焰晶
    const currentStones = gameData.spiritStones || 0
    if (currentStones < cost) {
      return res.status(400).json({ error: '焰晶不足' })
    }
    
    // 检查背包容量
    const items = gameData.items || []
    const equipCount = items.filter(i => i.type && i.type !== 'pill' && i.type !== 'pet' && i.stats).length
    const petCount = items.filter(i => i.type === 'pet').length
    
    const storageExpand = gameData.storageExpand || {}
    const equipLimitLevel = storageExpand.equip || 0
    const petLimitLevel = storageExpand.pet || 0
    const equipLimit = storageConfig.equip.base + storageConfig.equip.perLevel * equipLimitLevel
    const petLimit = storageConfig.pet.base + storageConfig.pet.perLevel * petLimitLevel
    
    if (type === 'equipment' && equipCount >= equipLimit) {
      return res.status(400).json({ error: `装备背包已满(${equipCount}/${equipLimit})` })
    }
    if (type === 'pet' && petCount >= petLimit) {
      return res.status(400).json({ error: `宠物背包已满(${petCount}/${petLimit})` })
    }
    if (type === 'all' && equipCount >= equipLimit && petCount >= petLimit) {
      return res.status(400).json({ error: '装备和宠物背包均已满' })
    }
    
    // 自动处理设置
    const autoSellQualities = gameData.autoSellQualities || []
    const autoReleaseRarities = gameData.autoReleaseRarities || []
    
    // 获取或初始化保底计数
    if (!gameData.gachaPity) {
      gameData.gachaPity = { equipCount: 0, petCount: 0 }
    }
    const pity = gameData.gachaPity
    
    // 抽卡
    const results = []
    let autoSold = { count: 0, income: 0 }
    let autoReleased = 0
    let petEssenceGained = 0
    let highestEquipQuality = null
    let highestPetRarity = null
    
    // 获取宠物品质配置（用于精华计算）
    const petProbsConfig = await getConfig('gacha_pet_probs')
    const essenceBonusMap = {
      divine: 50, celestial: 30, mystic: 20, spiritual: 10, mortal: 5
    }
    
    for (let i = 0; i < count; i++) {
      let item
      let drawnQuality = null
      let drawnRarity = null
      
      // 增加保底计数
      pity.equipCount++
      pity.petCount++
      
      if (type === 'all') {
        const { item: drawnItem, type: drawnType, quality, rarity } = await drawFromAllPool(level, wishlistEnabled, wishEquipQuality, wishPetRarity, gachaRateBoost, pity)
        item = drawnItem
        if (drawnType === 'equipment') drawnQuality = quality
        if (drawnType === 'pet') drawnRarity = rarity
      } else if (type === 'equipment') {
        const { item: drawnItem, quality } = await drawSingleEquip(level, wishlistEnabled, wishEquipQuality, gachaRateBoost, pity)
        item = drawnItem
        item.category = 'equipment'
        drawnQuality = quality
      } else {
        const { item: drawnItem, rarity } = await drawSinglePet(wishlistEnabled, wishPetRarity, gachaRateBoost, pity)
        item = drawnItem
        item.type = 'pet'
        drawnRarity = rarity
      }
      
      // 保底重置逻辑：出 epic+ 重置计数器（类似原神大小保底）
      // 50抽保底epic → 100抽保底legendary → 200抽保底mythic
      // 中途出了 epic+ 就重置，重新累积
      const qualityRank = { common: 0, uncommon: 1, rare: 2, epic: 3, legendary: 4, mythic: 5 }
      if (drawnQuality && qualityRank[drawnQuality] >= 3) {
        pity.equipCount = 0
        if (!highestEquipQuality || qualityRank[drawnQuality] > qualityRank[highestEquipQuality]) {
          highestEquipQuality = drawnQuality
        }
      }
      if (drawnRarity === 'divine' || drawnRarity === 'celestial' || drawnRarity === 'mystic') {
        pity.petCount = 0
        highestPetRarity = drawnRarity
      }
      
      // 自动处理逻辑
      if (item.type === 'pet') {
        // 增加宠物精华
        petEssenceGained += essenceBonusMap[item.rarity] || 5
        
        // 自动放生检查
        if (autoReleaseRarities.length > 0 && (autoReleaseRarities.includes('all') || autoReleaseRarities.includes(item.rarity))) {
          autoReleased++
          continue
        }
      } else {
        // 自动出售检查
        if (autoSellQualities.length > 0 && (autoSellQualities.includes('all') || autoSellQualities.includes(item.quality))) {
          const price = sellPrices[item.quality] || 1
          autoSold.count++
          autoSold.income += price
          continue
        }
      }
      
      results.push(item)
    }
    
    // 扣除焰晶并更新数据
    const newStones = currentStones - cost
    gameData.spiritStones = newStones
    gameData.petEssence = (gameData.petEssence || 0) + petEssenceGained
    gameData.reinforceStones = (gameData.reinforceStones || 0) + autoSold.income
    gameData.gachaPity = pity
    
    // 添加物品到背包
    results.forEach(item => {
      item.id = Date.now() + Math.random()
      items.push(item)
    })
    gameData.items = items
    
    // 保存到数据库
    await pool.query(
      'UPDATE players SET game_data = $1, spirit_stones = $2 WHERE wallet = $3',
      [JSON.stringify(gameData), newStones, wallet]
    )
    
    res.json({
      results,
      cost,
      autoSold,
      autoReleased,
      spiritStones: newStones,
      petEssenceGained,
      pity: {
        equipCount: pity.equipCount,
        petCount: pity.petCount,
        highestEquipQuality,
        highestPetRarity
      }
    })
  } catch (e) {
    console.error('Gacha draw error:', e)
    res.status(500).json({ error: e.message })
  }
})

export { generateEquipment, generatePet, equipmentQualities, equipmentTypes, equipmentBaseStats }
export default router
