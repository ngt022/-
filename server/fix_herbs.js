import pg from 'pg';

const pool = new pg.Pool({
  connectionString: 'postgresql://roon_user:RoonG%40ming2026!@localhost:5432/xiuxian'
});

const wallet = '0x82e402b05f3e936b63a874788c73e1552657c4f7';

const herbDefs = [
  { id: 'spirit_grass', name: '灵精草', baseValue: 10, category: 'spirit' },
  { id: 'cloud_flower', name: '云雾花', baseValue: 15, category: 'cultivation' },
  { id: 'thunder_root', name: '雷击根', baseValue: 25, category: 'attribute' },
  { id: 'dragon_breath_herb', name: '龙息草', baseValue: 40, category: 'special' },
  { id: 'immortal_jade_grass', name: '仙玉草', baseValue: 60, category: 'special' },
  { id: 'dark_yin_grass', name: '玄阴草', baseValue: 30, category: 'spirit' },
  { id: 'nine_leaf_lingzhi', name: '九叶灵芝', baseValue: 45, category: 'cultivation' },
  { id: 'purple_ginseng', name: '紫金参', baseValue: 50, category: 'attribute' },
  { id: 'frost_lotus', name: '寒霜莲', baseValue: 55, category: 'spirit' },
  { id: 'fire_heart_flower', name: '火心花', baseValue: 35, category: 'attribute' },
  { id: 'moonlight_orchid', name: '月华兰', baseValue: 70, category: 'spirit' },
  { id: 'sun_essence_flower', name: '日精花', baseValue: 75, category: 'cultivation' },
  { id: 'five_elements_grass', name: '五行草', baseValue: 80, category: 'attribute' },
  { id: 'phoenix_feather_herb', name: '凤羽草', baseValue: 85, category: 'special' },
  { id: 'celestial_dew_grass', name: '天露草', baseValue: 90, category: 'special' },
];

const qMap = { common: 1, uncommon: 1.5, rare: 2, epic: 3, legendary: 5 };

const herbs = [];
for (const h of herbDefs) {
  for (const [qk, qv] of Object.entries(qMap)) {
    for (let i = 0; i < 20; i++) {
      herbs.push({ id: h.id, name: h.name, baseValue: h.baseValue, category: h.category, quality: qk, value: Math.floor(h.baseValue * qv) });
    }
  }
}

const allRecipes = [
  'spirit_gathering','cultivation_boost','thunder_power','immortal_essence',
  'five_elements_pill','celestial_essence_pill','sun_moon_pill','phoenix_rebirth_pill',
  'spirit_recovery','essence_condensation','mind_clarity','fire_essence'
];

const pillDefs = [
  { recipeId:'spirit_gathering', name:'聚灵丹', grade:'grade1', effect:{type:'spiritRate',value:0.2,duration:3600} },
  { recipeId:'cultivation_boost', name:'聚气丹', grade:'grade2', effect:{type:'cultivationRate',value:0.3,duration:1800} },
  { recipeId:'thunder_power', name:'雷灵丹', grade:'grade3', effect:{type:'combatBoost',value:0.4,duration:900} },
  { recipeId:'immortal_essence', name:'仙灵丹', grade:'grade4', effect:{type:'allAttributes',value:0.5,duration:600} },
  { recipeId:'five_elements_pill', name:'五行丹', grade:'grade5', effect:{type:'allAttributes',value:0.8,duration:1200} },
  { recipeId:'celestial_essence_pill', name:'天元丹', grade:'grade6', effect:{type:'cultivationRate',value:1.0,duration:1800} },
  { recipeId:'sun_moon_pill', name:'日月丹', grade:'grade7', effect:{type:'spiritCap',value:1.5,duration:2400} },
  { recipeId:'phoenix_rebirth_pill', name:'涅槃丹', grade:'grade8', effect:{type:'autoHeal',value:0.1,duration:3600} },
  { recipeId:'spirit_recovery', name:'回灵丹', grade:'grade2', effect:{type:'spiritRecovery',value:0.4,duration:1200} },
  { recipeId:'essence_condensation', name:'凝元丹', grade:'grade3', effect:{type:'cultivationEfficiency',value:0.5,duration:1500} },
  { recipeId:'mind_clarity', name:'清心丹', grade:'grade3', effect:{type:'comprehension',value:0.3,duration:2400} },
  { recipeId:'fire_essence', name:'火元丹', grade:'grade4', effect:{type:'fireAttribute',value:0.6,duration:1800} },
];

const pills = [];
for (const p of pillDefs) {
  for (let i = 0; i < 5; i++) {
    pills.push({ ...p, createdAt: Date.now() });
  }
}

async function run() {
  const result = await pool.query('SELECT game_data FROM players WHERE wallet = ', [wallet]);
  const gd = result.rows[0].game_data;
  
  gd.herbs = herbs;
  gd.pills = pills;
  gd.pillRecipes = allRecipes;
  gd.pillsCrafted = 50;
  gd.pillsConsumed = 20;
  
  const jsonStr = JSON.stringify(gd);
  // Use text type parameter to avoid jsonb parsing issues
  await pool.query({
    text: 'UPDATE players SET game_data =  WHERE wallet = ',
    values: [jsonStr, wallet],
    types: { getTypeParser: () => (val) => val }
  });
  
  console.log('Done!');
  console.log('Herbs:', herbs.length);
  console.log('Pills:', pills.length);
  console.log('Recipes:', allRecipes.length);
  
  await pool.end();
}

run().catch(e => { console.error(e); process.exit(1); });
