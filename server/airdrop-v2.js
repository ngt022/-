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

const pillNames = {
  'spirit_gathering': '聚灵丹',
  'cultivation_boost': '聚气丹',
  'thunder_power': '雷灵丹',
  'immortal_essence': '仙灵丹',
  'five_elements_pill': '五行丹',
  'celestial_essence_pill': '天元丹',
  'sun_moon_pill': '日月丹',
  'phoenix_rebirth_pill': '涅槃丹',
  'spirit_recovery': '回灵丹',
  'essence_condensation': '凝元丹',
  'mind_clarity': '清心丹',
  'fire_essence': '火元丹'
}

const userId = 3

async function airdrop() {
  try {
    console.log('🎁 开始空投给用户', userId)
    
    // 1. 空投12种完整焰方
    for (const recipeId of recipes) {
      await pool.query(
        `INSERT INTO pill_recipes (user_id, recipe_id) VALUES ($1, $2) ON CONFLICT (user_id, recipe_id) DO NOTHING`,
        [userId, recipeId]
      )
    }
    console.log('✅ 已空投12种完整焰方')
    
    // 2. 空投60个焰丹（12种×5个）
    for (const recipeId of recipes) {
      for (let i = 0; i < 5; i++) {
        await pool.query(
          `INSERT INTO pills (owner_id, recipe_id, name, effect) VALUES ($1, $2, $3, '{}')`,
          [userId, recipeId, pillNames[recipeId]]
        )
      }
    }
    console.log('✅ 已空投60个焰丹（12种×5个）')
    
    await pool.end()
    console.log('🎉 空投完成！')
    process.exit(0)
  } catch (err) {
    console.error('❌ Error:', err)
    await pool.end()
    process.exit(1)
  }
}

airdrop()
