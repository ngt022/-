// 地点配置
export const locations = [
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
  // 铸炉期地点
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
  // 凝焰期地点
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
  // 焰婴期地点
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
  // 化焰期地点
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
  }
]

// 计算实际获取概率（考虑幸运值）
export const calculateRewardChance = (baseChance, luck = 1) => {
  return Math.min(baseChance * luck, 1) // 确保概率不超过100%
}
