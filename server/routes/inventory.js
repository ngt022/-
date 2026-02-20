import { Router } from 'express'
import pool from '../db.js'
import { auth } from '../middleware/auth.js'

const router = Router()

// 焰丹配置（和前端保持一致）
const PILL_RECIPES = {
  spirit_gathering: { name: '聚灵丹', grade: 1, materials: [{ herb: 'spirit_grass', count: 2 }, { herb: 'cloud_flower', count: 1 }], successRate: 0.9 },
  cultivation_boost: { name: '聚气丹', grade: 2, materials: [{ herb: 'cloud_flower', count: 2 }, { herb: 'thunder_root', count: 1 }], successRate: 0.8 },
  thunder_power: { name: '雷灵丹', grade: 3, materials: [{ herb: 'thunder_root', count: 2 }, { herb: 'dragon_breath_herb', count: 1 }], successRate: 0.7 },
  immortal_essence: { name: '仙灵丹', grade: 4, materials: [{ herb: 'dragon_breath_herb', count: 2 }, { herb: 'immortal_jade_grass', count: 1 }], successRate: 0.6 },
  five_elements_pill: { name: '五行丹', grade: 5, materials: [{ herb: 'five_elements_grass', count: 2 }, { herb: 'phoenix_feather_herb', count: 1 }], successRate: 0.5 },
  celestial_essence_pill: { name: '天元丹', grade: 6, materials: [{ herb: 'celestial_dew_grass', count: 2 }, { herb: 'moonlight_orchid', count: 1 }], successRate: 0.4 },
  sun_moon_pill: { name: '日月丹', grade: 7, materials: [{ herb: 'sun_essence_flower', count: 2 }, { herb: 'moonlight_orchid', count: 2 }], successRate: 0.3 },
  phoenix_rebirth_pill: { name: '涅槃丹', grade: 8, materials: [{ herb: 'phoenix_feather_herb', count: 3 }, { herb: 'celestial_dew_grass', count: 1 }], successRate: 0.2 },
  spirit_recovery: { name: '回灵丹', grade: 2, materials: [{ herb: 'dark_yin_grass', count: 2 }, { herb: 'frost_lotus', count: 1 }], successRate: 0.8 },
  essence_condensation: { name: '凝元丹', grade: 3, materials: [{ herb: 'nine_leaf_lingzhi', count: 2 }, { herb: 'purple_ginseng', count: 1 }], successRate: 0.7 },
  mind_clarity: { name: '清心丹', grade: 3, materials: [{ herb: 'frost_lotus', count: 2 }, { herb: 'fire_heart_flower', count: 1 }], successRate: 0.7 },
  fire_essence: { name: '火元丹', grade: 4, materials: [{ herb: 'fire_heart_flower', count: 2 }, { herb: 'dragon_breath_herb', count: 1 }], successRate: 0.6 },
}

// GET /api/inventory/herbs — 获取焰草
router.get('/herbs', auth, async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM herbs WHERE owner_id = $1 ORDER BY created_at DESC', [req.user.userId])
    res.json({ success: true, data: result.rows })
  } catch (err) {
    console.error('Get herbs error:', err)
    res.status(500).json({ success: false, message: '服务器错误' })
  }
})

// POST /api/inventory/herbs — 添加焰草
router.post('/herbs', auth, async (req, res) => {
  try {
    const { herbId, name, quality, value } = req.body
    if (!herbId || !name || !quality) return res.status(400).json({ success: false, message: '参数不完整' })

    const result = await pool.query(
      'INSERT INTO herbs (owner_id, herb_id, name, quality, value) VALUES ($1, $2, $3, $4, $5) RETURNING *',
      [req.user.userId, herbId, name, quality, value || 0]
    )
    res.json({ success: true, data: result.rows[0] })
  } catch (err) {
    console.error('Add herb error:', err)
    res.status(500).json({ success: false, message: '服务器错误' })
  }
})

// GET /api/inventory/pills — 获取焰丹
router.get('/pills', auth, async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM pills WHERE owner_id = $1 ORDER BY created_at DESC', [req.user.userId])
    res.json({ success: true, data: result.rows })
  } catch (err) {
    console.error('Get pills error:', err)
    res.status(500).json({ success: false, message: '服务器错误' })
  }
})

// POST /api/inventory/pills/use — 使用焰丹
router.post('/pills/use', auth, async (req, res) => {
  try {
    const { pillId } = req.body
    if (!pillId) return res.status(400).json({ success: false, message: '缺少焰丹ID' })

    const pill = await pool.query('SELECT * FROM pills WHERE id = $1 AND owner_id = $2', [pillId, req.user.userId])
    if (pill.rows.length === 0) return res.status(404).json({ success: false, message: '焰丹不存在' })

    const effect = pill.rows[0].effect || {}
    // 如果有持续效果，添加到 active_effects
    if (effect.duration) {
      const now = Date.now()
      await pool.query(
        'INSERT INTO active_effects (user_id, effect_type, effect_value, start_time, end_time) VALUES ($1, $2, $3, $4, $5)',
        [req.user.userId, effect.type || 'buff', effect.value || 0, now, now + effect.duration]
      )
    }

    // 删除已使用的焰丹
    await pool.query('DELETE FROM pills WHERE id = $1', [pillId])
    // 更新统计
    await pool.query('UPDATE player_data SET pills_consumed = pills_consumed + 1 WHERE user_id = $1', [req.user.userId])

    res.json({ success: true, data: { effect, message: '使用成功' } })
  } catch (err) {
    console.error('Use pill error:', err)
    res.status(500).json({ success: false, message: '服务器错误' })
  }
})

// GET /api/inventory/recipes — 获取已学配方
router.get('/recipes', auth, async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM pill_recipes WHERE user_id = $1', [req.user.userId])
    res.json({ success: true, data: result.rows })
  } catch (err) {
    console.error('Get recipes error:', err)
    res.status(500).json({ success: false, message: '服务器错误' })
  }
})

// POST /api/inventory/craft — 炼丹（网游化完整版）
router.post('/craft', auth, async (req, res) => {
  const client = await pool.connect()
  try {
    await client.query('BEGIN')
    
    const { recipeId } = req.body
    if (!recipeId) {
      await client.query('ROLLBACK')
      return res.status(400).json({ success: false, message: '缺少配方ID' })
    }

    const recipe = PILL_RECIPES[recipeId]
    if (!recipe) {
      await client.query('ROLLBACK')
      return res.status(400).json({ success: false, message: '未知配方' })
    }

    // 1. 检查是否学会了配方
    const recipeLearned = await client.query(
      'SELECT * FROM pill_recipes WHERE user_id = $1 AND recipe_id = $2',
      [req.user.userId, recipeId]
    )
    if (recipeLearned.rows.length === 0) {
      await client.query('ROLLBACK')
      return res.status(400).json({ success: false, message: '未学会该配方' })
    }

    // 2. 获取玩家属性（幸运值、炼丹率）
    const playerData = await client.query(
      'SELECT luck, alchemy_rate, level FROM player_data WHERE user_id = $1',
      [req.user.userId]
    )
    if (playerData.rows.length === 0) {
      await client.query('ROLLBACK')
      return res.status(404).json({ success: false, message: '玩家数据不存在' })
    }
    const { luck = 1, alchemy_rate = 1, level = 1 } = playerData.rows[0]

    // 3. 检查材料是否足够
    const userHerbs = await client.query('SELECT id, herb_id FROM herbs WHERE owner_id = $1', [req.user.userId])
    const herbMap = {}
    userHerbs.rows.forEach(h => {
      if (!herbMap[h.herb_id]) herbMap[h.herb_id] = []
      herbMap[h.herb_id].push(h.id)
    })

    for (const material of recipe.materials) {
      const have = herbMap[material.herb]?.length || 0
      if (have < material.count) {
        await client.query('ROLLBACK')
        return res.status(400).json({ 
          success: false, 
          message: `材料不足: ${material.herb} (${have}/${material.count})` 
        })
      }
    }

    // 4. 扣除材料
    for (const material of recipe.materials) {
      const herbIds = herbMap[material.herb].slice(0, material.count)
      for (const herbId of herbIds) {
        await client.query('DELETE FROM herbs WHERE id = $1', [herbId])
      }
    }

    // 5. 计算成功率
    const baseRate = recipe.successRate
    const luckBonus = (luck - 1) * 0.05
    const alchemyBonus = (alchemy_rate - 1) * 0.1
    const finalRate = Math.min(0.95, baseRate + luckBonus + alchemyBonus)

    // 6. 判定成功/失败
    const isSuccess = Math.random() < finalRate

    if (!isSuccess) {
      await client.query('ROLLBACK')
      return res.json({ success: false, message: '炼丹失败', rate: finalRate })
    }

    // 7. 计算效果
    const gradeMultiplier = 1 + (recipe.grade - 1) * 0.2
    const levelMultiplier = 1 + (level - 1) * 0.1
    const effectValue = recipe.grade * gradeMultiplier * levelMultiplier

    const effectMap = {
      1: { type: 'spiritRate', value: 0.2, duration: 3600000 },
      2: { type: 'cultivationRate', value: 0.3, duration: 1800000 },
      3: { type: 'combatBoost', value: 0.4, duration: 900000 },
      4: { type: 'allAttributes', value: 0.5, duration: 600000 },
      5: { type: 'allAttributes', value: 0.8, duration: 1200000 },
      6: { type: 'cultivationRate', value: 1.0, duration: 1800000 },
      7: { type: 'spiritCap', value: 1.5, duration: 2400000 },
      8: { type: 'autoHeal', value: 0.1, duration: 3600000 },
    }
    const baseEffect = effectMap[recipe.grade] || effectMap[1]
    const effect = {
      type: baseEffect.type,
      value: baseEffect.value * levelMultiplier,
      duration: baseEffect.duration
    }

    // 8. 创建焰丹
    const result = await client.query(
      `INSERT INTO pills (owner_id, recipe_id, name, description, effect) 
       VALUES ($1, $2, $3, $4, $5) RETURNING *`,
      [req.user.userId, recipeId, recipe.name, `由${recipe.name}方炼制`, JSON.stringify(effect)]
    )

    // 9. 更新统计
    await client.query(
      'UPDATE player_data SET pills_crafted = pills_crafted + 1 WHERE user_id = $1',
      [req.user.userId]
    )

    await client.query('COMMIT')
    res.json({ 
      success: true, 
      data: result.rows[0],
      message: '炼丹成功',
      rate: finalRate,
      effect
    })

  } catch (err) {
    await client.query('ROLLBACK')
    console.error('Craft error:', err)
    res.status(500).json({ success: false, message: '服务器错误' })
  } finally {
    client.release()
  }
})

// POST /api/inventory/pills/add — GM空投焰丹
router.post("/pills/add", auth, async (req, res) => {
  try {
    const { recipeId, name, description, effect } = req.body
    if (!name) return res.status(400).json({ success: false, message: "缺少焰丹名称" })
    const effectJson = typeof effect === "string" ? effect : JSON.stringify(effect || {})
    const result = await pool.query(
      "INSERT INTO pills (owner_id, recipe_id, name, description, effect) VALUES ($1, $2, $3, $4, $5) RETURNING *",
      [req.user.userId, recipeId || null, name, description || "", effectJson]
    )
    res.json({ success: true, data: result.rows[0] })
  } catch (err) {
    console.error("Add pill error:", err)
    res.status(500).json({ success: false, message: "服务器错误" })
  }
})

export default router
