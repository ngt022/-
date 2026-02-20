// 装备品质
const equipmentQualities = {
  common: { name: '凡品', color: '#9e9e9e', statMod: 1.0, maxStatMod: 1.5 },
  uncommon: { name: '下品', color: '#4caf50', statMod: 1.2, maxStatMod: 2.0 },
  rare: { name: '中品', color: '#2196f3', statMod: 1.5, maxStatMod: 2.5 },
  epic: { name: '上品', color: '#9c27b0', statMod: 2.0, maxStatMod: 3.0 },
  legendary: { name: '极品', color: '#ff9800', statMod: 2.5, maxStatMod: 3.5 },
  mythic: { name: '仙品', color: '#e91e63', statMod: 3.0, maxStatMod: 4.0 }
}

// 装备类型
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
  weapon: { attack: { min: 10, max: 20 }, critRate: { min: 0.05, max: 0.1 }, critDamageBoost: { min: 0.1, max: 0.3 } },
  head: { defense: { min: 5, max: 10 }, health: { min: 50, max: 100 }, stunResist: { min: 0.05, max: 0.1 } },
  body: { defense: { min: 8, max: 15 }, health: { min: 80, max: 150 }, finalDamageReduce: { min: 0.05, max: 0.1 } },
  legs: { defense: { min: 6, max: 12 }, speed: { min: 5, max: 10 }, dodgeRate: { min: 0.05, max: 0.1 } },
  feet: { defense: { min: 4, max: 8 }, speed: { min: 8, max: 15 }, dodgeRate: { min: 0.05, max: 0.1 } },
  shoulder: { defense: { min: 5, max: 10 }, health: { min: 40, max: 80 }, counterRate: { min: 0.05, max: 0.1 } },
  hands: { attack: { min: 5, max: 10 }, critRate: { min: 0.03, max: 0.08 }, comboRate: { min: 0.05, max: 0.1 } },
  wrist: { defense: { min: 3, max: 8 }, counterRate: { min: 0.05, max: 0.1 }, vampireRate: { min: 0.05, max: 0.1 } },
  necklace: { health: { min: 60, max: 120 }, healBoost: { min: 0.1, max: 0.2 }, spiritRate: { min: 0.1, max: 0.2 } },
  ring1: { attack: { min: 5, max: 10 }, critDamageBoost: { min: 0.1, max: 0.2 }, finalDamageBoost: { min: 0.05, max: 0.1 } },
  ring2: { defense: { min: 5, max: 10 }, critDamageReduce: { min: 0.1, max: 0.2 }, resistanceBoost: { min: 0.05, max: 0.1 } },
  belt: { health: { min: 40, max: 80 }, defense: { min: 4, max: 8 }, combatBoost: { min: 0.05, max: 0.1 } },
  artifact: { attack: { min: 8, max: 18 }, critRate: { min: 0.05, max: 0.15 }, comboRate: { min: 0.05, max: 0.15 } }
}

const percentStats = ['critRate', 'critDamageBoost', 'dodgeRate', 'vampireRate', 'finalDamageBoost', 'finalDamageReduce',
  'comboRate', 'counterRate', 'stunResist', 'healBoost', 'spiritRate', 'critDamageReduce', 'resistanceBoost', 'combatBoost']

// 生成装备名称
function generateEquipmentName(type, quality) {
  const typeInfo = equipmentTypes[type]
  const prefix = typeInfo.prefixes[Math.floor(Math.random() * typeInfo.prefixes.length)]
  const suffixes = { mythic: '·神', legendary: '·圣', epic: '·道', rare: '·天', uncommon: '·真', common: '' }
  return `${prefix}${typeInfo.name}${suffixes[quality] || ''}`
}

// 生成装备
function generateEquipment(level, type = null, quality = null) {
  if (!type) {
    const types = Object.keys(equipmentTypes)
    type = types[Math.floor(Math.random() * types.length)]
  }
  if (!quality) {
    const roll = Math.random()
    if (roll < 0.40) quality = 'common'
    else if (roll < 0.70) quality = 'uncommon'
    else if (roll < 0.87) quality = 'rare'
    else if (roll < 0.95) quality = 'epic'
    else if (roll < 0.985) quality = 'legendary'
    else quality = 'mythic'
  }

  const randomLevel = Math.floor(Math.random() * level) + 1
  const baseStats = {}
  const qualityMod = equipmentQualities[quality].statMod
  const levelMod = 1 + randomLevel * 0.1

  Object.entries(equipmentBaseStats[type]).forEach(([stat, config]) => {
    const base = config.min + Math.random() * (config.max - config.min)
    const value = base * qualityMod * levelMod
    if (percentStats.includes(stat)) {
      baseStats[stat] = Math.round(value * 10000) / 10000
    } else {
      baseStats[stat] = Math.round(value)
    }
  })

  return {
    name: generateEquipmentName(type, quality),
    type,
    slot: type,
    quality,
    level: randomLevel,
    requiredRealm: randomLevel,
    stats: baseStats,
    qualityInfo: equipmentQualities[quality]
  }
}

// 强化装备
function enhanceEquipment(equipment) {
  const stats = typeof equipment.stats === 'string' ? JSON.parse(equipment.stats) : { ...equipment.stats }
  const currentLevel = equipment.enhance_level || 0
  if (currentLevel >= 100) return { ...equipment, stats }

  // 每级属性提升2%基础值（线性增长，100级=+200%=3倍）
  // 公式：newVal = baseVal * (1 + (level+1)*0.02) / (1 + level*0.02)
  const oldMul = 1 + currentLevel * 0.02
  const newMul = 1 + (currentLevel + 1) * 0.02
  const ratio = newMul / oldMul
  for (const [key, val] of Object.entries(stats)) {
    if (typeof val === 'number') {
      if (percentStats.includes(key)) {
        stats[key] = Math.round(val * ratio * 10000) / 10000
      } else {
        stats[key] = Math.round(val * ratio)
      }
    }
  }
  return { ...equipment, enhance_level: currentLevel + 1, stats }
}

// 铭符（洗练）装备 - 在当前属性基础上±30%浮动
function reforgeEquipment(equipment) {
  const stats = typeof equipment.stats === 'string' ? JSON.parse(equipment.stats) : { ...equipment.stats }
  const newStats = {}
  for (const [key, val] of Object.entries(stats)) {
    if (typeof val === 'number') {
      const delta = (Math.random() * 0.6 - 0.3) // -30% to +30%
      const newVal = val * (1 + delta)
      if (percentStats.includes(key)) {
        newStats[key] = Math.round(newVal * 10000) / 10000
      } else {
        newStats[key] = Math.max(1, Math.round(newVal))
      }
    } else {
      newStats[key] = val
    }
  }
  return { ...equipment, stats: newStats }
}

// 卖出价格
const sellPrices = { common: 50, uncommon: 150, rare: 500, epic: 2000, legendary: 8000, mythic: 30000 }

export { equipmentQualities, equipmentTypes, equipmentBaseStats, generateEquipment, generateEquipmentName, enhanceEquipment, reforgeEquipment, sellPrices }
