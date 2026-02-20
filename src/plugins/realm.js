// 境界名称配置
// prettier-ignore
const realms = [
  // 燃火期
  { name: '燃火一重', maxCultivation: 100 }, { name: '燃火二重', maxCultivation: 200 },
  { name: '燃火三重', maxCultivation: 300 }, { name: '燃火四重', maxCultivation: 400 },
  { name: '燃火五重', maxCultivation: 500 }, { name: '燃火六重', maxCultivation: 600 },
  { name: '燃火七重', maxCultivation: 700 }, { name: '燃火八重', maxCultivation: 800 },
  { name: '燃火九重', maxCultivation: 900 },
  // 铸炉期
  { name: '铸炉一重', maxCultivation: 1000 }, { name: '铸炉二重', maxCultivation: 1200 },
  { name: '铸炉三重', maxCultivation: 1400 }, { name: '铸炉四重', maxCultivation: 1600 },
  { name: '铸炉五重', maxCultivation: 1800 }, { name: '铸炉六重', maxCultivation: 2000 },
  { name: '铸炉七重', maxCultivation: 2200 }, { name: '铸炉八重', maxCultivation: 2400 },
  { name: '铸炉九重', maxCultivation: 2600 },
  // 凝焰期
  { name: '凝焰一重', maxCultivation: 3000 }, { name: '凝焰二重', maxCultivation: 3500 },
  { name: '凝焰三重', maxCultivation: 4000 }, { name: '凝焰四重', maxCultivation: 4500 },
  { name: '凝焰五重', maxCultivation: 5000 }, { name: '凝焰六重', maxCultivation: 5500 },
  { name: '凝焰七重', maxCultivation: 6000 }, { name: '凝焰八重', maxCultivation: 6500 },
  { name: '凝焰九重', maxCultivation: 7000 },
  // 焰婴期
  { name: '焰婴一重', maxCultivation: 8000 }, { name: '焰婴二重', maxCultivation: 9000 },
  { name: '焰婴三重', maxCultivation: 10000 }, { name: '焰婴四重', maxCultivation: 11000 },
  { name: '焰婴五重', maxCultivation: 12000 }, { name: '焰婴六重', maxCultivation: 13000 },
  { name: '焰婴七重', maxCultivation: 14000 }, { name: '焰婴八重', maxCultivation: 15000 },
  { name: '焰婴九重', maxCultivation: 16000 },
  // 化焰期
  { name: '化焰一重', maxCultivation: 18000 }, { name: '化焰二重', maxCultivation: 20000 },
  { name: '化焰三重', maxCultivation: 22000 }, { name: '化焰四重', maxCultivation: 24000 },
  { name: '化焰五重', maxCultivation: 26000 }, { name: '化焰六重', maxCultivation: 28000 },
  { name: '化焰七重', maxCultivation: 30000 }, { name: '化焰八重', maxCultivation: 32000 },
  { name: '化焰九重', maxCultivation: 35000 },
  // 焰虚期
  { name: '焰虚一重', maxCultivation: 40000 }, { name: '焰虚二重', maxCultivation: 45000 },
  { name: '焰虚三重', maxCultivation: 50000 }, { name: '焰虚四重', maxCultivation: 55000 },
  { name: '焰虚五重', maxCultivation: 60000 }, { name: '焰虚六重', maxCultivation: 65000 },
  { name: '焰虚七重', maxCultivation: 70000 }, { name: '焰虚八重', maxCultivation: 75000 },
  { name: '焰虚九重', maxCultivation: 80000 },
  // 焰合期
  { name: '焰合一重', maxCultivation: 90000 }, { name: '焰合二重', maxCultivation: 100000 },
  { name: '焰合三重', maxCultivation: 110000 }, { name: '焰合四重', maxCultivation: 120000 },
  { name: '焰合五重', maxCultivation: 130000 }, { name: '焰合六重', maxCultivation: 140000 },
  { name: '焰合七重', maxCultivation: 150000 }, { name: '焰合八重', maxCultivation: 160000 },
  { name: '焰合九重', maxCultivation: 170000 },
  // 大焰期
  { name: '大焰一重', maxCultivation: 200000 }, { name: '大焰二重', maxCultivation: 230000 },
  { name: '大焰三重', maxCultivation: 260000 }, { name: '大焰四重', maxCultivation: 290000 },
  { name: '大焰五重', maxCultivation: 320000 }, { name: '大焰六重', maxCultivation: 350000 },
  { name: '大焰七重', maxCultivation: 380000 }, { name: '大焰八重', maxCultivation: 410000 },
  { name: '大焰九重', maxCultivation: 450000 },
  // 渡焰期
  { name: '渡焰一重', maxCultivation: 500000 }, { name: '渡焰二重', maxCultivation: 550000 },
  { name: '渡焰三重', maxCultivation: 600000 }, { name: '渡焰四重', maxCultivation: 650000 },
  { name: '渡焰五重', maxCultivation: 700000 }, { name: '渡焰六重', maxCultivation: 750000 },
  { name: '渡焰七重', maxCultivation: 800000 }, { name: '渡焰八重', maxCultivation: 850000 },
  { name: '渡焰九重', maxCultivation: 900000 },
  // 焰仙境
  { name: '焰仙一重', maxCultivation: 1000000 }, { name: '焰仙二重', maxCultivation: 1200000 },
  { name: '焰仙三重', maxCultivation: 1400000 }, { name: '焰仙四重', maxCultivation: 1600000 },
  { name: '焰仙五重', maxCultivation: 1800000 }, { name: '焰仙六重', maxCultivation: 2000000 },
  { name: '焰仙七重', maxCultivation: 2200000 }, { name: '焰仙八重', maxCultivation: 2400000 },
  { name: '焰仙九重', maxCultivation: 2600000 },
  // 真焰境
  { name: '真焰一重', maxCultivation: 3000000 }, { name: '真焰二重', maxCultivation: 3500000 },
  { name: '真焰三重', maxCultivation: 4000000 }, { name: '真焰四重', maxCultivation: 4500000 },
  { name: '真焰五重', maxCultivation: 5000000 }, { name: '真焰六重', maxCultivation: 5500000 },
  { name: '真焰七重', maxCultivation: 6000000 }, { name: '真焰八重', maxCultivation: 6500000 },
  { name: '真焰九重', maxCultivation: 7000000 },
  // 圣焰境
  { name: '圣焰一重', maxCultivation: 8000000 }, { name: '圣焰二重', maxCultivation: 9000000 },
  { name: '圣焰三重', maxCultivation: 10000000 }, { name: '圣焰四重', maxCultivation: 11000000 },
  { name: '圣焰五重', maxCultivation: 12000000 }, { name: '圣焰六重', maxCultivation: 13000000 },
  { name: '圣焰七重', maxCultivation: 14000000 }, { name: '圣焰八重', maxCultivation: 15000000 },
  { name: '圣焰九重', maxCultivation: 16000000 },
  // 永焰境
  { name: '永焰一重', maxCultivation: 20000000 }, { name: '永焰二重', maxCultivation: 24000000 },
  { name: '永焰三重', maxCultivation: 28000000 }, { name: '永焰四重', maxCultivation: 32000000 },
  { name: '永焰五重', maxCultivation: 36000000 }, { name: '永焰六重', maxCultivation: 40000000 },
  { name: '永焰七重', maxCultivation: 44000000 }, { name: '永焰八重', maxCultivation: 48000000 },
  { name: '永焰九重', maxCultivation: 52000000 },
  // 焰帝境
  { name: '焰帝一重', maxCultivation: 60000000 }, { name: '焰帝二重', maxCultivation: 70000000 },
  { name: '焰帝三重', maxCultivation: 80000000 }, { name: '焰帝四重', maxCultivation: 90000000 },
  { name: '焰帝五重', maxCultivation: 100000000 }, { name: '焰帝六重', maxCultivation: 110000000 },
  { name: '焰帝七重', maxCultivation: 120000000 }, { name: '焰帝八重', maxCultivation: 130000000 },
  { name: '焰帝九重', maxCultivation: 140000000 }
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
