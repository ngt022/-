import express from 'express';
const router = express.Router();

// ========== 境界配置 ==========
const realms = [
  {name:'燃火一重',maxCultivation:100},{name:'燃火二重',maxCultivation:200},
  {name:'燃火三重',maxCultivation:300},{name:'燃火四重',maxCultivation:400},
  {name:'燃火五重',maxCultivation:500},{name:'燃火六重',maxCultivation:600},
  {name:'燃火七重',maxCultivation:700},{name:'燃火八重',maxCultivation:800},
  {name:'燃火九重',maxCultivation:900},
  {name:'铸炉一重',maxCultivation:1000},{name:'铸炉二重',maxCultivation:1200},
  {name:'铸炉三重',maxCultivation:1400},{name:'铸炉四重',maxCultivation:1600},
  {name:'铸炉五重',maxCultivation:1800},{name:'铸炉六重',maxCultivation:2000},
  {name:'铸炉七重',maxCultivation:2200},{name:'铸炉八重',maxCultivation:2400},
  {name:'铸炉九重',maxCultivation:2600},
  {name:'凝焰一重',maxCultivation:3000},{name:'凝焰二重',maxCultivation:3500},
  {name:'凝焰三重',maxCultivation:4000},{name:'凝焰四重',maxCultivation:4500},
  {name:'凝焰五重',maxCultivation:5000},{name:'凝焰六重',maxCultivation:5500},
  {name:'凝焰七重',maxCultivation:6000},{name:'凝焰八重',maxCultivation:6500},
  {name:'凝焰九重',maxCultivation:7000},
  {name:'焰婴一重',maxCultivation:8000},{name:'焰婴二重',maxCultivation:9000},
  {name:'焰婴三重',maxCultivation:10000},{name:'焰婴四重',maxCultivation:11000},
  {name:'焰婴五重',maxCultivation:12000},{name:'焰婴六重',maxCultivation:13000},
  {name:'焰婴七重',maxCultivation:14000},{name:'焰婴八重',maxCultivation:15000},
  {name:'焰婴九重',maxCultivation:16000},
  {name:'化焰一重',maxCultivation:18000},{name:'化焰二重',maxCultivation:20000},
  {name:'化焰三重',maxCultivation:22000},{name:'化焰四重',maxCultivation:24000},
  {name:'化焰五重',maxCultivation:26000},{name:'化焰六重',maxCultivation:28000},
  {name:'化焰七重',maxCultivation:30000},{name:'化焰八重',maxCultivation:32000},
  {name:'化焰九重',maxCultivation:35000},
  {name:'焰虚一重',maxCultivation:40000},{name:'焰虚二重',maxCultivation:45000},
  {name:'焰虚三重',maxCultivation:50000},{name:'焰虚四重',maxCultivation:55000},
  {name:'焰虚五重',maxCultivation:60000},{name:'焰虚六重',maxCultivation:65000},
  {name:'焰虚七重',maxCultivation:70000},{name:'焰虚八重',maxCultivation:75000},
  {name:'焰虚九重',maxCultivation:80000},
  {name:'焰合一重',maxCultivation:90000},{name:'焰合二重',maxCultivation:100000},
  {name:'焰合三重',maxCultivation:110000},{name:'焰合四重',maxCultivation:120000},
  {name:'焰合五重',maxCultivation:130000},{name:'焰合六重',maxCultivation:140000},
  {name:'焰合七重',maxCultivation:150000},{name:'焰合八重',maxCultivation:160000},
  {name:'焰合九重',maxCultivation:170000},
  {name:'大焰一重',maxCultivation:200000},{name:'大焰二重',maxCultivation:230000},
  {name:'大焰三重',maxCultivation:260000},{name:'大焰四重',maxCultivation:290000},
  {name:'大焰五重',maxCultivation:320000},{name:'大焰六重',maxCultivation:350000},
  {name:'大焰七重',maxCultivation:380000},{name:'大焰八重',maxCultivation:410000},
  {name:'大焰九重',maxCultivation:450000},
  {name:'渡焰一重',maxCultivation:500000},{name:'渡焰二重',maxCultivation:550000},
  {name:'渡焰三重',maxCultivation:600000},{name:'渡焰四重',maxCultivation:650000},
  {name:'渡焰五重',maxCultivation:700000},{name:'渡焰六重',maxCultivation:750000},
  {name:'渡焰七重',maxCultivation:800000},{name:'渡焰八重',maxCultivation:850000},
  {name:'渡焰九重',maxCultivation:900000},
  {name:'焰仙一重',maxCultivation:1000000},{name:'焰仙二重',maxCultivation:1200000},
  {name:'焰仙三重',maxCultivation:1400000},{name:'焰仙四重',maxCultivation:1600000},
  {name:'焰仙五重',maxCultivation:1800000},{name:'焰仙六重',maxCultivation:2000000},
  {name:'焰仙七重',maxCultivation:2200000},{name:'焰仙八重',maxCultivation:2400000},
  {name:'焰仙九重',maxCultivation:2600000},
  {name:'真焰一重',maxCultivation:3000000},{name:'真焰二重',maxCultivation:3500000},
  {name:'真焰三重',maxCultivation:4000000},{name:'真焰四重',maxCultivation:4500000},
  {name:'真焰五重',maxCultivation:5000000},{name:'真焰六重',maxCultivation:5500000},
  {name:'真焰七重',maxCultivation:6000000},{name:'真焰八重',maxCultivation:6500000},
  {name:'真焰九重',maxCultivation:7000000},
  {name:'圣焰一重',maxCultivation:8000000},{name:'圣焰二重',maxCultivation:9000000},
  {name:'圣焰三重',maxCultivation:10000000},{name:'圣焰四重',maxCultivation:11000000},
  {name:'圣焰五重',maxCultivation:12000000},{name:'圣焰六重',maxCultivation:13000000},
  {name:'圣焰七重',maxCultivation:14000000},{name:'圣焰八重',maxCultivation:15000000},
  {name:'圣焰九重',maxCultivation:16000000},
  {name:'永焰一重',maxCultivation:20000000},{name:'永焰二重',maxCultivation:24000000},
  {name:'永焰三重',maxCultivation:28000000},{name:'永焰四重',maxCultivation:32000000},
  {name:'永焰五重',maxCultivation:36000000},{name:'永焰六重',maxCultivation:40000000},
  {name:'永焰七重',maxCultivation:44000000},{name:'永焰八重',maxCultivation:48000000},
  {name:'永焰九重',maxCultivation:52000000},
  {name:'焰帝一重',maxCultivation:60000000},{name:'焰帝二重',maxCultivation:70000000},
  {name:'焰帝三重',maxCultivation:80000000},{name:'焰帝四重',maxCultivation:90000000},
  {name:'焰帝五重',maxCultivation:100000000},{name:'焰帝六重',maxCultivation:110000000},
  {name:'焰帝七重',maxCultivation:120000000},{name:'焰帝八重',maxCultivation:130000000},
  {name:'焰帝九重',maxCultivation:140000000}
];

// ========== 探索地点 ==========
const locations = [
  {id:'newbie_village',name:'薪火村',description:'焰气初生之地，适合初入修焰之道的焰修。',minLevel:1,spiritCost:50,icon:'🏘️'},
  {id:'celestial_mountain',name:'赤霄峰',description:'赤焰缭绕的焰山，传说是远古焰仙讲道之地。',minLevel:10,spiritCost:1500,icon:'⛰️'},
  {id:'phoenix_valley',name:'涅槃谷',description:'常年被烈焰环绕的神秘山谷，据说有凤凰涅槃遗留的焰韵。',minLevel:19,spiritCost:2000,icon:'🔥'},
  {id:'dragon_abyss',name:'焰渊',description:'深不见底的神秘深渊，蕴含远古焰龙的气息。',minLevel:28,spiritCost:3000,icon:'🐉'},
  {id:'immortal_realm',name:'焰天圣域入口',description:'焰气最为浓郁的至高圣域，唯有化焰期以上的焰修方可踏入。',minLevel:37,spiritCost:5000,icon:'✨'}
];

// ========== 装备配置 ==========
const equipmentSlots = ['weapon','head','body','legs','feet','ring','necklace','artifact'];
const equipmentSlotNames = {weapon:'武器',head:'头盔',body:'铠甲',legs:'护腿',feet:'战靴',ring:'戒指',necklace:'项链',artifact:'法器'};
const equipmentQualities = [
  {id:'common',name:'凡品',color:'#9e9e9e',statMultiplier:1,sellPrice:20},
  {id:'uncommon',name:'良品',color:'#4caf50',statMultiplier:1.5,sellPrice:50},
  {id:'rare',name:'优品',color:'#2196f3',statMultiplier:2.5,sellPrice:200},
  {id:'epic',name:'极品',color:'#9c27b0',statMultiplier:4,sellPrice:1000},
  {id:'legendary',name:'仙品',color:'#ff9800',statMultiplier:7,sellPrice:5000},
  {id:'mythic',name:'神品',color:'#f44336',statMultiplier:12,sellPrice:10000}
];

// ========== 焰草配置 ==========
const herbQualities = {
  common:{name:'普通',multiplier:1,color:'#9e9e9e'},
  uncommon:{name:'优质',multiplier:1.5,color:'#4caf50'},
  rare:{name:'稀有',multiplier:2,color:'#2196f3'},
  epic:{name:'史诗',multiplier:3,color:'#9c27b0'},
  legendary:{name:'传说',multiplier:5,color:'#ff9800'}
};
const herbTypes = [
  {id:'spirit_grass',name:'灵精草',baseValue:10},
  {id:'cloud_flower',name:'云雾花',baseValue:15},
  {id:'thunder_root',name:'雷击根',baseValue:25},
  {id:'fire_heart_flower',name:'火心花',baseValue:35},
  {id:'dragon_breath_herb',name:'龙息草',baseValue:40},
  {id:'nine_leaf_lingzhi',name:'九叶灵芝',baseValue:45},
  {id:'purple_ginseng',name:'紫金参',baseValue:50},
  {id:'frost_lotus',name:'寒霜莲',baseValue:55},
  {id:'immortal_jade_grass',name:'仙玉草',baseValue:60},
  {id:'dark_yin_grass',name:'玄阴草',baseValue:30},
  {id:'moonlight_orchid',name:'月华兰',baseValue:70},
  {id:'sun_essence_flower',name:'日精花',baseValue:75},
  {id:'five_elements_grass',name:'五行草',baseValue:80},
  {id:'phoenix_feather_herb',name:'凤羽草',baseValue:85},
  {id:'celestial_dew_grass',name:'天露草',baseValue:90}
];
const herbTiers = {
  1:['spirit_grass','cloud_flower','dark_yin_grass'],
  2:['spirit_grass','cloud_flower','thunder_root','fire_heart_flower','dark_yin_grass'],
  3:['thunder_root','dragon_breath_herb','nine_leaf_lingzhi','fire_heart_flower','purple_ginseng'],
  4:['purple_ginseng','frost_lotus','immortal_jade_grass','nine_leaf_lingzhi','dragon_breath_herb'],
  5:['moonlight_orchid','sun_essence_flower','five_elements_grass','phoenix_feather_herb','celestial_dew_grass']
};

// ========== 丹药配方 ==========
const pillRecipes = [
  {id:'spirit_gathering',name:'聚灵丹',grade:'grade1',effect:{type:'spirit',value:500},materials:[{herb:'spirit_grass',count:3}]},
  {id:'cultivation_boost',name:'聚气丹',grade:'grade1',effect:{type:'cultivation',value:200},materials:[{herb:'cloud_flower',count:3}]},
  {id:'thunder_power',name:'雷灵丹',grade:'grade2',effect:{type:'attack',value:50,duration:300000},materials:[{herb:'thunder_root',count:3},{herb:'spirit_grass',count:2}]},
  {id:'immortal_essence',name:'仙灵丹',grade:'grade3',effect:{type:'allStats',value:30,duration:600000},materials:[{herb:'immortal_jade_grass',count:3},{herb:'purple_ginseng',count:2}]},
  {id:'five_elements_pill',name:'五行丹',grade:'grade4',effect:{type:'cultivation',value:2000},materials:[{herb:'five_elements_grass',count:3},{herb:'frost_lotus',count:2}]},
  {id:'celestial_essence_pill',name:'天元丹',grade:'grade5',effect:{type:'spirit',value:5000},materials:[{herb:'celestial_dew_grass',count:3},{herb:'moonlight_orchid',count:2}]},
  {id:'sun_moon_pill',name:'日月丹',grade:'grade4',effect:{type:'critRate',value:0.1,duration:600000},materials:[{herb:'sun_essence_flower',count:3},{herb:'moonlight_orchid',count:2}]},
  {id:'phoenix_rebirth_pill',name:'涅槃丹',grade:'grade5',effect:{type:'revive',value:1},materials:[{herb:'phoenix_feather_herb',count:5},{herb:'celestial_dew_grass',count:3}]},
  {id:'spirit_recovery',name:'回灵丹',grade:'grade1',effect:{type:'spirit',value:300},materials:[{herb:'cloud_flower',count:2},{herb:'spirit_grass',count:1}]},
  {id:'essence_condensation',name:'凝元丹',grade:'grade2',effect:{type:'defense',value:40,duration:300000},materials:[{herb:'dark_yin_grass',count:3},{herb:'thunder_root',count:2}]},
  {id:'mind_clarity',name:'清心丹',grade:'grade2',effect:{type:'dodgeRate',value:0.05,duration:300000},materials:[{herb:'nine_leaf_lingzhi',count:3},{herb:'cloud_flower',count:2}]},
  {id:'fire_essence',name:'火元丹',grade:'grade3',effect:{type:'attack',value:100,duration:600000},materials:[{herb:'fire_heart_flower',count:3},{herb:'dragon_breath_herb',count:2}]}
];

// ========== 副本 Buff ==========
const dungeonBuffs = [
  {id:'atk_up',name:'焰力激增',desc:'攻击+30%',effect:{attack:0.3}},
  {id:'def_up',name:'焰甲护体',desc:'防御+30%',effect:{defense:0.3}},
  {id:'hp_up',name:'焰命延续',desc:'生命+30%',effect:{health:0.3}},
  {id:'crit_up',name:'焰心通明',desc:'暴击+15%',effect:{critRate:0.15}},
  {id:'dodge_up',name:'焰影步',desc:'闪避+10%',effect:{dodgeRate:0.1}},
  {id:'vampire_up',name:'焰噬',desc:'吸血+10%',effect:{vampireRate:0.1}},
  {id:'combo_up',name:'焰连击',desc:'连击+10%',effect:{comboRate:0.1}},
  {id:'speed_up',name:'焰速',desc:'速度+20%',effect:{speed:0.2}}
];

// ========== VIP 配置 ==========
const vipConfig = [
  {level:0,name:'普通',cultivationBoost:1,extraDrop:0,offlineBoost:1},
  {level:1,name:'VIP1',cultivationBoost:1.1,extraDrop:0.05,offlineBoost:1.1},
  {level:2,name:'VIP2',cultivationBoost:1.2,extraDrop:0.1,offlineBoost:1.2},
  {level:3,name:'VIP3',cultivationBoost:1.5,extraDrop:0.15,offlineBoost:1.5},
  {level:4,name:'VIP4',cultivationBoost:1.8,extraDrop:0.2,offlineBoost:1.8},
  {level:5,name:'VIP5',cultivationBoost:2.0,extraDrop:0.3,offlineBoost:2.0}
];

// ========== 数值公式 ==========
const formulas = {
  maxSpirit: {desc:'焰灵上限',formula:'200 + level * 100'},
  spiritRegen: {desc:'焰灵恢复/秒',formula:'2 + level * 0.5'},
  cultivationCost: {desc:'冥想消耗',formula:'5 + level * 3'},
  cultivationGain: {desc:'冥想收益',formula:'max(1, level * 2)'},
  breakthroughReward: {desc:'突破焰灵奖励',formula:'100 * level'}
};

// ========== 缓存 ==========
let cachedConfig = null;

function buildConfig() {
  if (cachedConfig) return cachedConfig;
  cachedConfig = {
    realms,
    locations,
    equipment: {slots:equipmentSlots, slotNames:equipmentSlotNames, qualities:equipmentQualities},
    herbs: {qualities:herbQualities, types:herbTypes, tiers:herbTiers},
    pills: pillRecipes,
    dungeonBuffs,
    vipConfig,
    formulas,
    version: Date.now()
  };
  return cachedConfig;
}

// GET /api/game/config - 下发所有游戏配置
router.get('/config', (req, res) => {
  res.json(buildConfig());
});

// 清除缓存（热更新用）
export function clearConfigCache() {
  cachedConfig = null;
}

export default router;
