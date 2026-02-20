// 焰草品质等级
export const herbQualities = {
  common: { name: '普通', value: 1 },
  uncommon: { name: '优质', value: 1.5 },
  rare: { name: '稀有', value: 2 },
  epic: { name: '极品', value: 3 },
  legendary: { name: '仙品', value: 5 }
}

// 焰草种类配置
export const herbs = [
  {
    id: 'spirit_grass',
    name: '灵精草',
    description: '最常见的焰草，蕴含少量焰灵。炼制聚灵丹的主要材料',
    baseValue: 10,
    category: 'spirit', // 焰灵类
    chance: 0.4 // 获取概率
  },
  {
    id: 'cloud_flower',
    name: '云雾花',
    description: '生长在云雾缭绕处的焰花，有助于焰修。可炼制：聚灵丹、聚气丹',
    baseValue: 15,
    category: 'cultivation', // 焰修类
    chance: 0.3
  },
  {
    id: 'thunder_root',
    name: '雷击根',
    description: '经过雷霆淬炼的焰根，蕴含强大能量。可炼制：聚气丹、雷灵丹',
    baseValue: 25,
    category: 'attribute', // 属性类
    chance: 0.15
  },
  {
    id: 'dragon_breath_herb',
    name: '龙息草',
    description: '吸收龙气孕育的焰草，极为珍贵。可炼制：雷灵丹、仙灵丹、火元丹',
    baseValue: 40,
    category: 'special', // 特殊类
    chance: 0.1
  },
  {
    id: 'immortal_jade_grass',
    name: '仙玉草',
    description: '传说中生长在仙境的焰草，可遇不可求。可炼制：仙灵丹',
    baseValue: 60,
    category: 'special',
    chance: 0.05
  },
  {
    id: 'dark_yin_grass',
    name: '玄阴草',
    description: '生长在阴暗处的奇特焰草，具有独特的焰灵属性。可炼制：回灵丹',
    baseValue: 30,
    category: 'spirit',
    chance: 0.2
  },
  {
    id: 'nine_leaf_lingzhi',
    name: '九叶灵芝',
    description: '传说中的灵芝，拥有九片叶子，蕴含强大的生命力。可炼制：凝元丹',
    baseValue: 45,
    category: 'cultivation',
    chance: 0.12
  },
  {
    id: 'purple_ginseng',
    name: '紫金参',
    description: '千年紫参，散发着淡淡的黄金，大补元气。可炼制：凝元丹',
    baseValue: 50,
    category: 'attribute',
    chance: 0.08
  },
  {
    id: 'frost_lotus',
    name: '寒霜莲',
    description: '生长在极寒之地的莲花，可以提升焰修者的焰灵纯度。可炼制：回灵丹、清心丹',
    baseValue: 55,
    category: 'spirit',
    chance: 0.07
  },
  {
    id: 'fire_heart_flower',
    name: '火心花',
    description: '生长在火山口的奇花，花心似火焰跳动。可炼制：清心丹、火元丹',
    baseValue: 35,
    category: 'attribute',
    chance: 0.15
  },
  {
    id: 'moonlight_orchid',
    name: '月华兰',
    description: '只在月圆之夜绽放的神秘兰花，能吸收月华精华。可炼制：天元丹、日月丹',
    baseValue: 70,
    category: 'spirit',
    chance: 0.04
  },
  {
    id: 'sun_essence_flower',
    name: '日精花',
    description: '吸收太阳精华的奇花，蕴含纯阳之力。可炼制：日月丹',
    baseValue: 75,
    category: 'cultivation',
    chance: 0.03
  },
  {
    id: 'five_elements_grass',
    name: '五行草',
    description: '一株草同时具备金木水火土五种属性的奇珍。可炼制：五行丹',
    baseValue: 80,
    category: 'attribute',
    chance: 0.02
  },
  {
    id: 'phoenix_feather_herb',
    name: '凤羽草',
    description: '传说生长在不死火凤栖息地的神草，具有涅槃之力。可炼制：五行丹、涅槃丹',
    baseValue: 85,
    category: 'special',
    chance: 0.015
  },
  {
    id: 'celestial_dew_grass',
    name: '天露草',
    description: '凝聚天地精华的焰草，千年一遇。可炼制：天元丹、涅槃丹',
    baseValue: 90,
    category: 'special',
    chance: 0.01
  }
]

// 根据品质获取焰草实际价值
export const getHerbValue = (herb, quality) => {
  return Math.floor(herb.baseValue * herbQualities[quality].value)
}

// 随机获取焰草
export const getRandomHerb = () => {
  const rand = Math.random()
  let cumulative = 0
  for (const herb of herbs) {
    cumulative += herb.chance
    if (rand <= cumulative) {
      // 随机决定品质
      const qualities = Object.keys(herbQualities)
      const qualityRand = Math.random()
      let quality
      if (qualityRand < 0.5) quality = qualities[0] // 50% 普通
      else if (qualityRand < 0.8) quality = qualities[1] // 30% 优质
      else if (qualityRand < 0.95) quality = qualities[2] // 15% 稀有
      else if (qualityRand < 0.99) quality = qualities[3] // 4% 极品
      else quality = qualities[4] // 1% 仙品
      return {
        ...herb,
        quality,
        value: getHerbValue(herb, quality)
      }
    }
  }
  return null
}
