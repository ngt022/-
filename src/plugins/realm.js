// 境界名称配置
// prettier-ignore
const realms = [
  // 燃火期
  { name: '燃火一重', maxCultivation: 100 }, { name: '燃火二重', maxCultivation: 200 },
  { name: '燃火三重', maxCultivation: 300 }, { name: '燃火四重', maxCultivation: 450 },
  { name: '燃火五重', maxCultivation: 600 }, { name: '燃火六重', maxCultivation: 750 },
  { name: '燃火七重', maxCultivation: 950 }, { name: '燃火八重', maxCultivation: 1200 },
  { name: '燃火九重', maxCultivation: 1400 },
  // 铸炉期
  { name: '铸炉一重', maxCultivation: 1700 }, { name: '铸炉二重', maxCultivation: 1400 },
  { name: '铸炉三重', maxCultivation: 1700 }, { name: '铸炉四重', maxCultivation: 2000 },
  { name: '铸炉五重', maxCultivation: 2200 }, { name: '铸炉六重', maxCultivation: 2600 },
  { name: '铸炉七重', maxCultivation: 2800 }, { name: '铸炉八重', maxCultivation: 3200 },
  { name: '铸炉九重', maxCultivation: 3500 },
  // 凝焰期
  { name: '凝焰一重', maxCultivation: 3900 }, { name: '凝焰二重', maxCultivation: 4300 },
  { name: '凝焰三重', maxCultivation: 4700 }, { name: '凝焰四重', maxCultivation: 5200 },
  { name: '凝焰五重', maxCultivation: 5700 }, { name: '凝焰六重', maxCultivation: 6100 },
  { name: '凝焰七重', maxCultivation: 6600 }, { name: '凝焰八重', maxCultivation: 7200 },
  { name: '凝焰九重', maxCultivation: 7700 },
  // 焰婴期
  { name: '焰婴一重', maxCultivation: 8300 }, { name: '焰婴二重', maxCultivation: 8900 },
  { name: '焰婴三重', maxCultivation: 9500 }, { name: '焰婴四重', maxCultivation: 10000 },
  { name: '焰婴五重', maxCultivation: 11000 }, { name: '焰婴六重', maxCultivation: 11000 },
  { name: '焰婴七重', maxCultivation: 12000 }, { name: '焰婴八重', maxCultivation: 13000 },
  { name: '焰婴九重', maxCultivation: 14000 },
  // 化焰期
  { name: '化焰一重', maxCultivation: 14000 }, { name: '化焰二重', maxCultivation: 15000 },
  { name: '化焰三重', maxCultivation: 16000 }, { name: '化焰四重', maxCultivation: 17000 },
  { name: '化焰五重', maxCultivation: 17000 }, { name: '化焰六重', maxCultivation: 18000 },
  { name: '化焰七重', maxCultivation: 19000 }, { name: '化焰八重', maxCultivation: 20000 },
  { name: '化焰九重', maxCultivation: 21000 },
  // 焰虚期
  { name: '焰虚一重', maxCultivation: 22000 }, { name: '焰虚二重', maxCultivation: 23000 },
  { name: '焰虚三重', maxCultivation: 24000 }, { name: '焰虚四重', maxCultivation: 25000 },
  { name: '焰虚五重', maxCultivation: 26000 }, { name: '焰虚六重', maxCultivation: 27000 },
  { name: '焰虚七重', maxCultivation: 28000 }, { name: '焰虚八重', maxCultivation: 29000 },
  { name: '焰虚九重', maxCultivation: 30000 },
  // 焰合期
  { name: '焰合一重', maxCultivation: 31000 }, { name: '焰合二重', maxCultivation: 32000 },
  { name: '焰合三重', maxCultivation: 33000 }, { name: '焰合四重', maxCultivation: 34000 },
  { name: '焰合五重', maxCultivation: 36000 }, { name: '焰合六重', maxCultivation: 37000 },
  { name: '焰合七重', maxCultivation: 77000 }, { name: '焰合八重', maxCultivation: 81000 },
  { name: '焰合九重', maxCultivation: 85000 },
  // 大焰期
  { name: '大焰一重', maxCultivation: 89000 }, { name: '大焰二重', maxCultivation: 93000 },
  { name: '大焰三重', maxCultivation: 97000 }, { name: '大焰四重', maxCultivation: 101000 },
  { name: '大焰五重', maxCultivation: 105000 }, { name: '大焰六重', maxCultivation: 110000 },
  { name: '大焰七重', maxCultivation: 114000 }, { name: '大焰八重', maxCultivation: 118000 },
  { name: '大焰九重', maxCultivation: 123000 },
  // 渡焰期
  { name: '渡焰一重', maxCultivation: 128000 }, { name: '渡焰二重', maxCultivation: 132000 },
  { name: '渡焰三重', maxCultivation: 137000 }, { name: '渡焰四重', maxCultivation: 142000 },
  { name: '渡焰五重', maxCultivation: 147000 }, { name: '渡焰六重', maxCultivation: 152000 },
  { name: '渡焰七重', maxCultivation: 157000 }, { name: '渡焰八重', maxCultivation: 162000 },
  { name: '渡焰九重', maxCultivation: 168000 },
  // 焰仙境
  { name: '焰仙一重', maxCultivation: 173000 }, { name: '焰仙二重', maxCultivation: 178000 },
  { name: '焰仙三重', maxCultivation: 184000 }, { name: '焰仙四重', maxCultivation: 189000 },
  { name: '焰仙五重', maxCultivation: 195000 }, { name: '焰仙六重', maxCultivation: 201000 },
  { name: '焰仙七重', maxCultivation: 207000 }, { name: '焰仙八重', maxCultivation: 213000 },
  { name: '焰仙九重', maxCultivation: 218000 },
  // 真焰境
  { name: '真焰一重', maxCultivation: 342000 }, { name: '真焰二重', maxCultivation: 357000 },
  { name: '真焰三重', maxCultivation: 372000 }, { name: '真焰四重', maxCultivation: 388000 },
  { name: '真焰五重', maxCultivation: 403000 }, { name: '真焰六重', maxCultivation: 419000 },
  { name: '真焰七重', maxCultivation: 435000 }, { name: '真焰八重', maxCultivation: 451000 },
  { name: '真焰九重', maxCultivation: 468000 },
  // 圣焰境
  { name: '圣焰一重', maxCultivation: 485000 }, { name: '圣焰二重', maxCultivation: 510000 },
  { name: '圣焰三重', maxCultivation: 535000 }, { name: '圣焰四重', maxCultivation: 561000 },
  { name: '圣焰五重', maxCultivation: 587000 }, { name: '圣焰六重', maxCultivation: 614000 },
  { name: '圣焰七重', maxCultivation: 641000 }, { name: '圣焰八重', maxCultivation: 669000 },
  { name: '圣焰九重', maxCultivation: 697000 },
  // 永焰境
  { name: '永焰一重', maxCultivation: 725000 }, { name: '永焰二重', maxCultivation: 754000 },
  { name: '永焰三重', maxCultivation: 783000 }, { name: '永焰四重', maxCultivation: 812000 },
  { name: '永焰五重', maxCultivation: 842000 }, { name: '永焰六重', maxCultivation: 873000 },
  { name: '永焰七重', maxCultivation: 903000 }, { name: '永焰八重', maxCultivation: 934000 },
  { name: '永焰九重', maxCultivation: 966000 },
  // 焰帝境
  { name: '焰帝一重', maxCultivation: 998000 }, { name: '焰帝二重', maxCultivation: 1030000 },
  { name: '焰帝三重', maxCultivation: 1063000 }, { name: '焰帝四重', maxCultivation: 1096000 },
  { name: '焰帝五重', maxCultivation: 1129000 }, { name: '焰帝六重', maxCultivation: 1163000 },
  { name: '焰帝七重', maxCultivation: 1197000 }, { name: '焰帝八重', maxCultivation: 1232000 },
  { name: '焰帝九重', maxCultivation: 1267000 }
]

// 境界图标映射（每9级一个阶段）
const realmImages = [
  '/assets/images/realm/realm_01_ranHuo.png',
  '/assets/images/realm/realm_02_zhuLu.png',
  '/assets/images/realm/realm_03_ningYan.png',
  '/assets/images/realm/realm_04_yanYing.png',
  '/assets/images/realm/realm_05_huaYan.png',
  '/assets/images/realm/realm_06_yanXu.png',
  '/assets/images/realm/realm_07_yanHe.png',
  '/assets/images/realm/realm_08_daYan.png',
  '/assets/images/realm/realm_09_duYan.png',
  '/assets/images/realm/realm_10_yanXian.png',
  '/assets/images/realm/realm_11_zhenYan.png',
  '/assets/images/realm/realm_12_shengYan.png',
  '/assets/images/realm/realm_13_yongYan.png',
  '/assets/images/realm/realm_14_yanDi.png',
]

// 根据 level 获取境界图标路径
export const getRealmImage = level => {
  const stage = Math.min(Math.floor((level - 1) / 9), realmImages.length - 1)
  return realmImages[stage]
}

// 获取境界名称
export const getRealmName = level => {
  if (level < 1) return realms[0]
  if (level > realms.length) return realms[realms.length - 1]
  return realms[level - 1]
}

export const getRealmLength = () => {
  return realms.length
}
