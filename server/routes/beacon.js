import { Router } from 'express'
import { auth } from '../middleware/auth.js'
import pool from '../db.js'

const router = Router()

// POST /api/game/save-beacon - 自动保存信标
router.post('/', auth, async (req, res) => {
  try {
    // 更新最后在线时间
    await pool.query(
      'UPDATE player_data SET last_online_time = $1, updated_at = NOW() WHERE user_id = $2',
      [Date.now(), req.user.userId]
    )
    res.json({ success: true })
  } catch (err) {
    res.status(500).json({ success: false, message: '保存失败' })
  }
})

export default router
