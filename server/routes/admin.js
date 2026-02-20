import { Router } from 'express'
import pool from '../db.js'
import { auth } from '../middleware/auth.js'

const router = Router()

// 管理员钱包地址列表
const ADMIN_WALLETS = [
  '0xbce51d77b325c1a42d2af8359f9744699102698e',
  '0xfad7eb0814b6838b05191a07fb987957d50c4ca9'
]

// 管理员权限验证中间件
function adminAuth(req, res, next) {
  if (!req.user || !ADMIN_WALLETS.includes(req.user.walletAddress?.toLowerCase())) {
    return res.status(403).json({ success: false, message: '无管理员权限' })
  }
  next()
}

// GET /api/admin/players — 玩家列表
router.get('/players', auth, adminAuth, async (req, res) => {
  try {
    const { page = 1, limit = 20 } = req.query
    const offset = (page - 1) * limit

    const countResult = await pool.query('SELECT COUNT(*) FROM users')
    const total = parseInt(countResult.rows[0].count)

    const result = await pool.query(
      `SELECT u.id, u.wallet_address, u.nickname, u.created_at, u.last_login, u.is_banned,
              p.level, p.realm, p.spirit_stones
       FROM users u LEFT JOIN player_data p ON u.id = p.user_id
       ORDER BY u.id DESC LIMIT $1 OFFSET $2`,
      [limit, offset]
    )

    res.json({ success: true, data: { players: result.rows, total, page: Number(page), limit: Number(limit) } })
  } catch (err) {
    console.error('Admin get players error:', err)
    res.status(500).json({ success: false, message: '服务器错误' })
  }
})

// PUT /api/admin/player/:userId — 修改玩家属性
router.put('/player/:userId', auth, adminAuth, async (req, res) => {
  try {
    const { userId } = req.params
    const data = req.body

    if (data.is_banned !== undefined) {
      await pool.query('UPDATE users SET is_banned = $1 WHERE id = $2', [data.is_banned, userId])
    }

    const playerFields = Object.keys(data).filter(k => k !== 'is_banned')
    if (playerFields.length > 0) {
      const updates = []
      const values = []
      let idx = 1
      for (const key of playerFields) {
        updates.push(`${key} = $${idx}`)
        values.push(data[key])
        idx++
      }
      values.push(userId)
      await pool.query(`UPDATE player_data SET ${updates.join(', ')}, updated_at = NOW() WHERE user_id = $${idx}`, values)
    }

    res.json({ success: true, message: '修改成功' })
  } catch (err) {
    console.error('Admin update player error:', err)
    res.status(500).json({ success: false, message: '服务器错误' })
  }
})

// POST /api/admin/airdrop — 空投物品
router.post('/airdrop', auth, adminAuth, async (req, res) => {
  try {
    const { userId, type, data } = req.body
    if (!userId || !type) return res.status(400).json({ success: false, message: '参数不完整' })

    const user = await pool.query('SELECT id FROM users WHERE id = $1', [userId])
    if (user.rows.length === 0) return res.status(404).json({ success: false, message: '用户不存在' })

    let result
    switch (type) {
      case 'spirit_stones':
        result = await pool.query(
          'UPDATE player_data SET spirit_stones = spirit_stones + $1 WHERE user_id = $2 RETURNING spirit_stones',
          [data.amount || 0, userId]
        )
        break
      case 'reinforce_stones':
        result = await pool.query(
          'UPDATE player_data SET reinforce_stones = reinforce_stones + $1 WHERE user_id = $2 RETURNING reinforce_stones',
          [data.amount || 0, userId]
        )
        break
      case 'refinement_stones':
        result = await pool.query(
          'UPDATE player_data SET refinement_stones = refinement_stones + $1 WHERE user_id = $2 RETURNING refinement_stones',
          [data.amount || 0, userId]
        )
        break
      case 'equipment':
        // 直接插入装备数据
        result = await pool.query(
          `INSERT INTO equipment (owner_id, name, type, slot, quality, level, required_realm, stats)
           VALUES ($1, $2, $3, $4, $5, $6, $7, $8) RETURNING *`,
          [userId, data.name, data.type, data.slot || data.type, data.quality, data.level || 1, data.requiredRealm || 1, JSON.stringify(data.stats || {})]
        )
        break
      case 'pill_recipe':
        // 空投焰方（完整丹方）
        await pool.query(
          'UPDATE player_data SET pill_recipes = array_append(pill_recipes, $1) WHERE user_id = $2 AND NOT ($1 = ANY(pill_recipes))',
          [data.recipeId, userId]
        )
        break
      case 'pill_fragment':
        // 空投焰方残页
        await pool.query(
          `INSERT INTO pill_fragments (user_id, recipe_id, fragments) 
           VALUES ($1, $2, $3) 
           ON CONFLICT (user_id, recipe_id) 
           DO UPDATE SET fragments = pill_fragments.fragments + $3`,
          [userId, data.recipeId, data.fragments || 1]
        )
        break
      default:
        return res.status(400).json({ success: false, message: '未知空投类型' })
    }

    res.json({ success: true, data: result?.rows?.[0], message: '空投成功' })
  } catch (err) {
    console.error('Admin airdrop error:', err)
    res.status(500).json({ success: false, message: '服务器错误' })
  }
})

// POST /api/admin/give-pill — 直接给焰丹
router.post('/give-pill', auth, adminAuth, async (req, res) => {
  try {
    const { userId, recipeId, name, description, effect } = req.body
    if (!userId || !recipeId) return res.status(400).json({ success: false, message: '参数不完整' })

    const user = await pool.query('SELECT id FROM users WHERE id = $1', [userId])
    if (user.rows.length === 0) return res.status(404).json({ success: false, message: '用户不存在' })

    // 插入焰丹到物品栏（ pills 表）
    const result = await pool.query(
      `INSERT INTO pills (owner_id, recipe_id, name, description, effect, created_at)
       VALUES ($1, $2, $3, $4, $5, NOW()) RETURNING *`,
      [userId, recipeId, name || '未知焰丹', description || '', JSON.stringify(effect || {})]
    )

    res.json({ success: true, data: result.rows[0], message: '焰丹空投成功' })
  } catch (err) {
    console.error('Admin give pill error:', err)
    res.status(500).json({ success: false, message: '服务器错误' })
  }
})

export default router
