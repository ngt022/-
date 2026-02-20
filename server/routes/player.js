import { Router } from 'express'
import pool from '../db.js'
import { auth } from '../middleware/auth.js'

const router = Router()

// GET /api/player — 获取当前玩家全部数据
router.get('/', auth, async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM player_data WHERE user_id = $1', [req.user.userId])
    if (result.rows.length === 0) return res.json({ success: true, data: null })
    res.json({ success: true, data: result.rows[0] })
  } catch (err) {
    console.error('Get player error:', err)
    res.status(500).json({ success: false, message: '服务器错误' })
  }
})

// PUT /api/player — 部分更新玩家数据
router.put('/', auth, async (req, res) => {
  try {
    const data = req.body
    if (!data || Object.keys(data).length === 0) {
      return res.status(400).json({ success: false, message: '无更新数据' })
    }

    // 允许更新的字段白名单
    const allowedFields = [
      'level', 'realm', 'cultivation', 'max_cultivation', 'spirit', 'spirit_rate',
      'luck', 'cultivation_rate', 'herb_rate', 'alchemy_rate',
      'spirit_stones', 'reinforce_stones', 'refinement_stones', 'pet_essence',
      'base_attack', 'base_health', 'base_defense', 'base_speed',
      'crit_rate', 'combo_rate', 'counter_rate', 'stun_rate', 'dodge_rate', 'vampire_rate',
      'crit_resist', 'combo_resist', 'counter_resist', 'stun_resist', 'dodge_resist', 'vampire_resist',
      'heal_boost', 'crit_damage_boost', 'crit_damage_reduce',
      'final_damage_boost', 'final_damage_reduce', 'combat_boost', 'resistance_boost',
      'breakthrough_count', 'exploration_count', 'items_found', 'pills_crafted', 'pills_consumed',
      'dungeon_highest_floor', 'dungeon_total_runs', 'dungeon_boss_kills',
      'last_online_time', 'is_auto_cultivating'
    ]

    const updates = []
    const values = []
    let idx = 1

    for (const [key, value] of Object.entries(data)) {
      if (allowedFields.includes(key)) {
        updates.push(`${key} = $${idx}`)
        values.push(value)
        idx++
      }
    }

    if (updates.length === 0) return res.status(400).json({ success: false, message: '无有效更新字段' })

    updates.push(`updated_at = NOW()`)
    values.push(req.user.userId)

    const sql = `UPDATE player_data SET ${updates.join(', ')} WHERE user_id = $${idx} RETURNING *`
    const result = await pool.query(sql, values)

    if (result.rows.length === 0) return res.status(404).json({ success: false, message: '玩家数据不存在' })
    res.json({ success: true, data: result.rows[0] })
  } catch (err) {
    console.error('Update player error:', err)
    res.status(500).json({ success: false, message: '服务器错误' })
  }
})

// POST /api/player/init — 初始化新玩家数据
router.post('/init', auth, async (req, res) => {
  try {
    const existing = await pool.query('SELECT id FROM player_data WHERE user_id = $1', [req.user.userId])
    if (existing.rows.length > 0) {
      return res.json({ success: true, data: existing.rows[0], message: '玩家数据已存在' })
    }

    const result = await pool.query(
      'INSERT INTO player_data (user_id, last_online_time) VALUES ($1, $2) RETURNING *',
      [req.user.userId, Date.now()]
    )
    res.json({ success: true, data: result.rows[0] })
  } catch (err) {
    console.error('Init player error:', err)
    res.status(500).json({ success: false, message: '服务器错误' })
  }
})

export default router
