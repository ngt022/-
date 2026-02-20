// 焰兽池
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
    { name: '睚眦', description: '龙之次子，性格刚烈，嗜杀好斗' },
    { name: '嘲风', description: '龙之三子，形似兽，喜好冒险' },
    { name: '蒲牢', description: '龙之四子，形似龙而小，性好鸣' },
    { name: '狻犴', description: '龙之五子，形似狮子，喜静好坐' },
    { name: '霸下', description: '龙之六子，形似龟，力大无穷' },
    { name: '狴犴', description: '龙之七子，形似虎，明辨是非' },
    { name: '负屃', description: '龙之八子，形似龙，雅好诗文' },
    { name: '螭吻', description: '龙之九子，形似鱼，能吞火' }
  ],
  mystic: [
    { name: '火凤凰', description: '浴火重生的永恒之鸟' },
    { name: '雷鹰', description: '雷电的猛禽' },
    { name: '冰狼', description: '冰原霸主' },
    { name: '岩龟', description: '坚不可摧的守护者' }
  ],
  spiritual: [
    { name: '玄龟', description: '擅长防御的水系焰兽' },
    { name: '风隼', description: '速度极快的飞行焰兽' },
    { name: '地甲', description: '坚固的大地守护者' },
    { name: '云豹', description: '敏捷的猎手' }
  ],
  mortal: [
    { name: '灵猫', description: '敏捷的小型焰兽' },
    { name: '幻蝶', description: '美丽的蝴蝶焰兽' },
    { name: '火鼠', description: '活泼的啮齿类焰兽' },
    { name: '草兔', description: '温顺的兔类焰兽' }
  ]
}

// 品质倍率
const rarityMultipliers = {
  divine: { base: 5, percent: 2 },
  celestial: { base: 4, percent: 1.8 },
  mystic: { base: 3, percent: 1.6 },
  spiritual: { base: 2, percent: 1.4 },
  mortal: { base: 1, percent: 1 }
}

function generateRandomValue(min, max, isPercentage = false) {
  const value = min + Math.random() * (max - min)
  return isPercentage ? Math.min(1, Math.round(value * 100) / 100) : Math.round(value)
}

function generateCombatAttributes(rarity) {
  const multiplier = rarityMultipliers[rarity] || rarityMultipliers.mortal
  const baseStats = {
    attack: { min: 10, max: 15, useBase: true },
    health: { min: 100, max: 120, useBase: true },
    defense: { min: 5, max: 8, useBase: true },
    speed: { min: 10, max: 15, useBase: true, multiplier: 0.6 },
    critRate: { min: 0.05, max: 0.1, isPercentage: true },
    comboRate: { min: 0.05, max: 0.1, isPercentage: true },
    counterRate: { min: 0.05, max: 0.1, isPercentage: true },
    stunRate: { min: 0.05, max: 0.1, isPercentage: true },
    dodgeRate: { min: 0.05, max: 0.1, isPercentage: true },
    vampireRate: { min: 0.05, max: 0.1, isPercentage: true },
    critResist: { min: 0.05, max: 0.1, isPercentage: true },
    comboResist: { min: 0.05, max: 0.1, isPercentage: true },
    counterResist: { min: 0.05, max: 0.1, isPercentage: true },
    stunResist: { min: 0.05, max: 0.1, isPercentage: true },
    dodgeResist: { min: 0.05, max: 0.1, isPercentage: true },
    vampireResist: { min: 0.05, max: 0.1, isPercentage: true },
    healBoost: { min: 0.05, max: 0.1, isPercentage: true },
    critDamageBoost: { min: 0.05, max: 0.1, isPercentage: true },
    critDamageReduce: { min: 0.05, max: 0.1, isPercentage: true },
    finalDamageBoost: { min: 0.05, max: 0.1, isPercentage: true },
    finalDamageReduce: { min: 0.05, max: 0.1, isPercentage: true },
    combatBoost: { min: 0.05, max: 0.1, isPercentage: true },
    resistanceBoost: { min: 0.05, max: 0.1, isPercentage: true }
  }

  const attributes = {}
  for (const [key, config] of Object.entries(baseStats)) {
    if (config.isPercentage) {
      attributes[key] = generateRandomValue(config.min * multiplier.percent, config.max * multiplier.percent, true)
    } else {
      const baseMul = config.useBase ? multiplier.base : multiplier.percent
      const finalMul = config.multiplier ? baseMul * config.multiplier : baseMul
      attributes[key] = generateRandomValue(config.min * finalMul, config.max * finalMul)
    }
  }
  return attributes
}

// 生成焰兽
function generatePet(rarity = null, petName = null) {
  if (!rarity) {
    const roll = Math.random()
    if (roll < 0.002) rarity = 'divine'
    else if (roll < 0.06) rarity = 'celestial'
    else if (roll < 0.22) rarity = 'mystic'
    else if (roll < 0.50) rarity = 'spiritual'
    else rarity = 'mortal'
  }

  const pool = petPool[rarity]
  if (!pool || pool.length === 0) return null

  let pet
  if (petName) {
    pet = pool.find(p => p.name === petName) || pool[Math.floor(Math.random() * pool.length)]
  } else {
    pet = pool[Math.floor(Math.random() * pool.length)]
  }

  return {
    name: pet.name,
    description: pet.description,
    rarity,
    level: 1,
    star: 0,
    combatAttributes: generateCombatAttributes(rarity)
  }
}

export { petPool, rarityMultipliers, generatePet, generateCombatAttributes }
