import logger from "../services/logger.js";
import { Router } from 'express'
import pool from '../db.js'
import { auth } from '../middleware/auth.js'
import { generatePet } from '../utils/pet-gen.js'

const router = Router()

// GET /api/pets — 获取玩家所有焰兽
router.get('/', auth, async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM pets WHERE owner_id = $1 ORDER BY created_at DESC', [req.user.userId])
    res.json({ success: true, data: result.rows })
  } catch (err) {
    logger.error('Get pets error:', err)
    res.status(500).json({ success: false, message: '服务器错误' })
  }
})

// POST /api/pets/generate — 生成焰兽
router.post('/generate', auth, async (req, res) => {
  try {
    const { rarity, petName } = req.body
    const pet = generatePet(rarity || null, petName || null)
    if (!pet) return res.status(400).json({ success: false, message: '生成失败' })

    const result = await pool.query(
      `INSERT INTO pets (owner_id, name, description, rarity, level, star, combat_attributes)
       VALUES ($1, $2, $3, $4, $5, $6, $7) RETURNING *`,
      [req.user.userId, pet.name, pet.description, pet.rarity, pet.level, pet.star, JSON.stringify(pet.combatAttributes)]
    )
    res.json({ success: true, data: result.rows[0] })
  } catch (err) {
    logger.error('Generate pet error:', err)
    res.status(500).json({ success: false, message: '服务器错误' })
  }
})

// PUT /api/pets/:id/deploy — 出战
router.put('/:id/deploy', auth, async (req, res) => {
  try {
    const { id } = req.params
    // 先召回所有已出战的
    await pool.query('UPDATE pets SET is_active = false WHERE owner_id = $1 AND is_active = true', [req.user.userId])
    const result = await pool.query(
      'UPDATE pets SET is_active = true WHERE id = $1 AND owner_id = $2 RETURNING *',
      [id, req.user.userId]
    )
    if (result.rows.length === 0) return res.status(404).json({ success: false, message: '焰兽不存在' })
    res.json({ success: true, data: result.rows[0] })
  } catch (err) {
    logger.error('Deploy pet error:', err)
    res.status(500).json({ success: false, message: '服务器错误' })
  }
})

// PUT /api/pets/:id/recall — 召回
router.put('/:id/recall', auth, async (req, res) => {
  try {
    const { id } = req.params
    const result = await pool.query(
      'UPDATE pets SET is_active = false WHERE id = $1 AND owner_id = $2 RETURNING *',
      [id, req.user.userId]
    )
    if (result.rows.length === 0) return res.status(404).json({ success: false, message: '焰兽不存在' })
    res.json({ success: true, data: result.rows[0] })
  } catch (err) {
    logger.error('Recall pet error:', err)
    res.status(500).json({ success: false, message: '服务器错误' })
  }
})

// PUT /api/pets/:id/upgrade — 升级
router.put('/:id/upgrade', auth, async (req, res) => {
  try {
    const { id } = req.params
    const pet = await pool.query('SELECT * FROM pets WHERE id = $1 AND owner_id = $2', [id, req.user.userId])
    if (pet.rows.length === 0) return res.status(404).json({ success: false, message: '焰兽不存在' })

    const item = pet.rows[0]
    const newLevel = item.level + 1
    // 升级时属性按比例增长
    const attrs = item.combat_attributes || {}
    const boosted = {}
    for (const [key, val] of Object.entries(attrs)) {
      if (typeof val === 'number') {
        boosted[key] = val < 1 ? Math.round((val * 1.08) * 1000) / 1000 : Math.round(val * 1.08)
      } else {
        boosted[key] = val
      }
    }

    const result = await pool.query(
      'UPDATE pets SET level = $1, combat_attributes = $2 WHERE id = $3 RETURNING *',
      [newLevel, JSON.stringify(boosted), id]
    )
    res.json({ success: true, data: result.rows[0] })
  } catch (err) {
    logger.error('Upgrade pet error:', err)
    res.status(500).json({ success: false, message: '服务器错误' })
  }
})

// PUT /api/pets/:id/evolve — 升星
router.put('/:id/evolve', auth, async (req, res) => {
  try {
    const { id } = req.params
    const pet = await pool.query('SELECT * FROM pets WHERE id = $1 AND owner_id = $2', [id, req.user.userId])
    if (pet.rows.length === 0) return res.status(404).json({ success: false, message: '焰兽不存在' })

    const item = pet.rows[0]
    if (item.star >= 10) return res.status(400).json({ success: false, message: '已达最高星级' })

    const newStar = item.star + 1
    const attrs = item.combat_attributes || {}
    const boosted = {}
    for (const [key, val] of Object.entries(attrs)) {
      if (typeof val === 'number') {
        boosted[key] = val < 1 ? Math.round((val * 1.15) * 1000) / 1000 : Math.round(val * 1.15)
      } else {
        boosted[key] = val
      }
    }

    const result = await pool.query(
      'UPDATE pets SET star = $1, combat_attributes = $2 WHERE id = $3 RETURNING *',
      [newStar, JSON.stringify(boosted), id]
    )
    res.json({ success: true, data: result.rows[0] })
  } catch (err) {
    logger.error('Evolve pet error:', err)
    res.status(500).json({ success: false, message: '服务器错误' })
  }
})

// DELETE /api/pets/:id/release — 放生
router.delete('/:id/release', auth, async (req, res) => {
  try {
    const { id } = req.params
    const pet = await pool.query('SELECT * FROM pets WHERE id = $1 AND owner_id = $2', [id, req.user.userId])
    if (pet.rows.length === 0) return res.status(404).json({ success: false, message: '焰兽不存在' })
    if (pet.rows[0].is_active) return res.status(400).json({ success: false, message: '请先召回焰兽' })

    const essenceReward = { divine: 50, celestial: 30, mystic: 20, spiritual: 10, mortal: 5 }
    const essence = essenceReward[pet.rows[0].rarity] || 5

    await pool.query('DELETE FROM pets WHERE id = $1', [id])
    await pool.query('UPDATE player_data SET pet_essence = pet_essence + $1 WHERE user_id = $2', [essence, req.user.userId])

    res.json({ success: true, data: { essenceGained: essence } })
  } catch (err) {
    logger.error('Release pet error:', err)
    res.status(500).json({ success: false, message: '服务器错误' })
  }
})

export default router
