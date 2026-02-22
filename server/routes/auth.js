import logger from "../services/logger.js";
import { Router } from 'express'
import jwt from 'jsonwebtoken'
import pool from '../db.js'
import { auth, JWT_SECRET } from '../middleware/auth.js'

const router = Router()

// POST /api/auth/login — 钱包登录，查找或创建用户
router.post('/login', async (req, res) => {
  try {
    const walletAddress = req.body.walletAddress || req.body.wallet
    if (!walletAddress) return res.status(400).json({ success: false, message: '缺少钱包地址' })

    const addr = walletAddress.toLowerCase()
    let result = await pool.query('SELECT * FROM users WHERE wallet_address = $1', [addr])

    if (result.rows.length === 0) {
      result = await pool.query(
        'INSERT INTO users (wallet_address) VALUES ($1) RETURNING *',
        [addr]
      )
    } else {
      await pool.query('UPDATE users SET last_login = NOW() WHERE id = $1', [result.rows[0].id])
    }

    const user = result.rows[0]
    if (user.is_banned) return res.status(403).json({ success: false, message: '账号已被封禁' })

    const token = jwt.sign(
      { userId: user.id, walletAddress: user.wallet_address },
      JWT_SECRET,
      { expiresIn: '7d' }
    )

    res.json({
      success: true,
      data: {
        token,
        user: {
          id: user.id,
          walletAddress: user.wallet_address,
          nickname: user.nickname,
          createdAt: user.created_at
        }
      }
    })
  } catch (err) {
    logger.error('Login error:', err)
    res.status(500).json({ success: false, message: '服务器错误' })
  }
})

// GET /api/auth/me — 获取当前用户信息
router.get('/me', auth, async (req, res) => {
  try {
    const result = await pool.query('SELECT id, wallet_address, nickname, nickname_changes, created_at, last_login FROM users WHERE id = $1', [req.user.userId])
    if (result.rows.length === 0) return res.status(404).json({ success: false, message: '用户不存在' })
    res.json({ success: true, data: result.rows[0] })
  } catch (err) {
    logger.error('Get me error:', err)
    res.status(500).json({ success: false, message: '服务器错误' })
  }
})

export default router
