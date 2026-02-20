import pool from './db.js'

const recipes = [
  'spirit_gathering',
  'cultivation_boost',
  'thunder_power',
  'immortal_essence',
  'five_elements_pill',
  'celestial_essence_pill',
  'sun_moon_pill',
  'phoenix_rebirth_pill',
  'spirit_recovery',
  'essence_condensation',
  'mind_clarity',
  'fire_essence'
]

const userId = 3

async function airdrop() {
  try {
    // 确保玩家数据存在
    await pool.query(
      `INSERT INTO player_data (user_id) VALUES ($1) ON CONFLICT (user_id) DO NOTHING`,
      [userId]
    )
    
    // 添加所有焰方
    for (const recipeId of recipes) {
      await pool.query(
        `UPDATE player_data SET pill_recipes = array_append(pill_recipes, $1) WHERE user_id = $2 AND NOT ($1 = ANY(pill_recipes))`,
        [recipeId, userId]
      )
    }
    
    console.log('✅ 已空投12种完整焰方给用户', userId)
    
    // 添加焰丹（通过inventory/pills表）
    const pills = [
      { recipe_id: 'spirit_gathering', name: '聚灵丹' },
      { recipe_id: 'cultivation_boost', name: '聚气丹' },
      { recipe_id: 'thunder_power', name: '雷灵丹' },
      { recipe_id: 'immortal_essence', name: '仙灵丹' },
      { recipe_id: 'five_elements_pill', name: '五行丹' },
      { recipe_id: 'celestial_essence_pill', name: '天元丹' },
      { recipe_id: 'sun_moon_pill', name: '日月丹' },
      { recipe_id: 'phoenix_rebirth_pill', name: '涅槃丹' },
      { recipe_id: 'spirit_recovery', name: '回灵丹' },
      { recipe_id: 'essence_condensation', name: '凝元丹' },
      { recipe_id: 'mind_clarity', name: '清心丹' },
      { recipe_id: 'fire_essence', name: '火元丹' },
    ]
    
    for (const pill of pills) {
      // 每种焰丹插入5个
      for (let i = 0; i < 5; i++) {
        await pool.query(
          `INSERT INTO pills (user_id, recipe_id, name, effect) VALUES ($1, $2, $3, '{}')`,
          [userId, pill.recipe_id, pill.name]
        )
      }
    }
    
    console.log('✅ 已空投60个焰丹（12种×5个）给用户', userId)
    
    await pool.end()
    process.exit(0)
  } catch (err) {
    console.error('❌ Error:', err)
    await pool.end()
    process.exit(1)
  }
}

airdrop()
