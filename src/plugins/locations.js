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
  },
  // 焰虚期地点
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
  // 焰合期地点
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
  // 大焰期地点
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
  // 渡焰期地点
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
]

// 计算实际获取概率（考虑幸运值）
export const calculateRewardChance = (baseChance, luck = 1) => {
  return Math.min(baseChance * luck, 1) // 确保概率不超过100%
}
