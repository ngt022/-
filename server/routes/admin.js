import logger from "../services/logger.js";
import { Router } from 'express'

export default (pool, auth, adminAuth) => {
  const router = Router()

  // 辅助函数：记录管理员日志
  async function logAdminAction(wallet, action, target, details = {}) {
    try {
      await pool.query(
        `INSERT INTO admin_logs (admin_wallet, action, target, details, created_at) 
         VALUES ($1, $2, $3, $4, NOW())`,
        [wallet, action, target, JSON.stringify(details)]
      )
    } catch (err) {
      logger.error('Admin log error:', err)
    }
  }

  // 辅助函数：确保表存在
  async function ensureTables() {
    try {
      // 创建 announcements 表
      await pool.query(`
        CREATE TABLE IF NOT EXISTS announcements (
          id SERIAL PRIMARY KEY,
          title TEXT NOT NULL,
          content TEXT NOT NULL,
          created_at TIMESTAMPTZ DEFAULT NOW(),
          updated_at TIMESTAMPTZ DEFAULT NOW()
        )
      `)

      // 创建 admin_logs 表
      await pool.query(`
        CREATE TABLE IF NOT EXISTS admin_logs (
          id SERIAL PRIMARY KEY,
          admin_wallet TEXT NOT NULL,
          action TEXT NOT NULL,
          target TEXT,
          details JSONB DEFAULT '{}',
          created_at TIMESTAMPTZ DEFAULT NOW()
        )
      `)

      // 创建 settings 表
      await pool.query(`
        CREATE TABLE IF NOT EXISTS settings (
          id SERIAL PRIMARY KEY,
          key TEXT UNIQUE NOT NULL,
          value JSONB NOT NULL,
          updated_at TIMESTAMPTZ DEFAULT NOW()
        )
      `)
    } catch (err) {
      logger.error('Ensure tables error:', err)
    }
  }

  // 初始化表
  ensureTables()

  // ==================== 已有路由 ====================

  // GET /api/admin/players — 玩家列表
  router.get('/players', auth, adminAuth, async (req, res) => {
    try {
      const { page = 1, limit = 20, search = '' } = req.query
      const offset = (page - 1) * limit

      let whereClause = ''
      let params = [limit, offset]
      
      if (search) {
        whereClause = "WHERE p.wallet ILIKE $3 OR p.name ILIKE $3"
        params = [limit, offset, `%${search}%`]
      }

      const countResult = await pool.query(`
        SELECT COUNT(*) FROM players p ${whereClause}
      `, search ? [`%${search}%`] : [])
      const total = parseInt(countResult.rows[0].count)

      const result = await pool.query(
        `SELECT p.id, p.wallet, p.name, p.created_at, p.updated_at, p.banned,
                p.level, p.realm, p.spirit_stones, p.vip_level, p.combat_power
         FROM players p ${whereClause}
         ORDER BY p.id DESC LIMIT $1 OFFSET $2`,
        params
      )

      res.json({ success: true, data: { players: result.rows, total, page: Number(page), limit: Number(limit) } })
    } catch (err) {
      logger.error('Admin get players error:', err)
      res.status(500).json({ success: false, message: '服务器错误' })
    }
  })

  // PUT /api/admin/player/:userId — 修改玩家属性
  router.put('/player/:userId', auth, adminAuth, async (req, res) => {
    try {
      const { userId } = req.params
      const data = req.body
      const adminWallet = req.user.wallet

      // 获取玩家当前数据用于日志
      const oldPlayer = await pool.query('SELECT * FROM players WHERE id = $1', [userId])
      if (oldPlayer.rows.length === 0) {
        return res.status(404).json({ success: false, message: '玩家不存在' })
      }

      const updates = []
      const values = []
      let idx = 1

      // 处理 banned
      if (data.banned !== undefined) {
        updates.push(`banned = $${idx}`)
        values.push(data.banned)
        idx++
      }

      // 处理其他字段
      const allowedFields = ['name', 'level', 'realm', 'spirit_stones', 'vip_level', 'combat_power']
      for (const key of allowedFields) {
        if (data[key] !== undefined) {
          updates.push(`${key} = $${idx}`)
          values.push(data[key])
          idx++
        }
      }

      if (updates.length > 0) {
        values.push(userId)
        await pool.query(`UPDATE players SET ${updates.join(', ')}, updated_at = NOW() WHERE id = $${idx}`, values)
        
        // 记录日志
        await logAdminAction(adminWallet, 'UPDATE_PLAYER', userId, { 
          old: oldPlayer.rows[0], 
          new: data 
        })
      }

      res.json({ success: true, message: '修改成功' })
    } catch (err) {
      logger.error('Admin update player error:', err)
      res.status(500).json({ success: false, message: '服务器错误' })
    }
  })

  // POST /api/admin/airdrop — 空投物品
  router.post('/airdrop', auth, adminAuth, async (req, res) => {
    try {
      const { wallet, type, data } = req.body
      const adminWallet = req.user.wallet
      
      if (!wallet || !type) return res.status(400).json({ success: false, message: '参数不完整' })

      const user = await pool.query('SELECT id, game_data FROM players WHERE wallet = $1', [wallet])
      if (user.rows.length === 0) return res.status(404).json({ success: false, message: '用户不存在' })

      let result
      let gd = typeof user.rows[0].game_data === 'string' ? JSON.parse(user.rows[0].game_data) : (user.rows[0].game_data || {})

      switch (type) {
        case 'spirit_stones':
          const newStones = (gd.spiritStones || 0) + (data.amount || 0)
          gd.spiritStones = newStones
          await pool.query(
            'UPDATE players SET spirit_stones = $1, game_data = $2 WHERE wallet = $3',
            [newStones, JSON.stringify(gd), wallet]
          )
          result = { spirit_stones: newStones }
          break
        
        case 'reinforce_stones':
          gd.reinforceStones = (gd.reinforceStones || 0) + (data.amount || 0)
          await pool.query(
            'UPDATE players SET game_data = $1 WHERE wallet = $2',
            [JSON.stringify(gd), wallet]
          )
          result = { reinforce_stones: gd.reinforceStones }
          break
        
        case 'refinement_stones':
          gd.refinementStones = (gd.refinementStones || 0) + (data.amount || 0)
          await pool.query(
            'UPDATE players SET game_data = $1 WHERE wallet = $2',
            [JSON.stringify(gd), wallet]
          )
          result = { refinement_stones: gd.refinementStones }
          break
        
        case 'equipment':
          if (!gd.items) gd.items = []
          const equipItem = {
            id: 'equip_' + Date.now(),
            name: data.name,
            type: data.type,
            quality: data.quality,
            level: data.level || 1,
            stats: data.stats || {},
            attributes: data.attributes || {}
          }
          gd.items.push(equipItem)
          await pool.query(
            'UPDATE players SET game_data = $1 WHERE wallet = $2',
            [JSON.stringify(gd), wallet]
          )
          result = equipItem
          break

        case 'pill_recipe':
          if (!gd.pillRecipes) gd.pillRecipes = []
          if (!gd.pillRecipes.includes(data.recipeId)) {
            gd.pillRecipes.push(data.recipeId)
            await pool.query(
              'UPDATE players SET game_data = $1 WHERE wallet = $2',
              [JSON.stringify(gd), wallet]
            )
          }
          result = { pill_recipes: gd.pillRecipes }
          break

        case 'pet':
          if (!gd.items) gd.items = []
          const petItem = {
            id: 'pet_' + Date.now(),
            type: 'pet',
            name: data.name,
            rarity: data.rarity || 'mortal',
            level: 1,
            star: 0,
            combatAttributes: data.combatAttributes || {}
          }
          gd.items.push(petItem)
          await pool.query(
            'UPDATE players SET game_data = $1 WHERE wallet = $2',
            [JSON.stringify(gd), wallet]
          )
          result = petItem
          break

        default:
          return res.status(400).json({ success: false, message: '未知空投类型' })
      }

      // 记录日志
      await logAdminAction(adminWallet, 'AIRDROP', wallet, { type, data })

      res.json({ success: true, data: result, message: '空投成功' })
    } catch (err) {
      logger.error('Admin airdrop error:', err)
      res.status(500).json({ success: false, message: '服务器错误' })
    }
  })

  // POST /api/admin/give-pill — 直接给焰丹
  router.post('/give-pill', auth, adminAuth, async (req, res) => {
    try {
      const { wallet, pill } = req.body
      const adminWallet = req.user.wallet
      
      if (!wallet || !pill) return res.status(400).json({ success: false, message: '参数不完整' })

      const user = await pool.query('SELECT id, game_data FROM players WHERE wallet = $1', [wallet])
      if (user.rows.length === 0) return res.status(404).json({ success: false, message: '用户不存在' })

      let gd = typeof user.rows[0].game_data === 'string' ? JSON.parse(user.rows[0].game_data) : (user.rows[0].game_data || {})
      if (!gd.items) gd.items = []

      const pillItem = {
        id: 'pill_' + Date.now(),
        type: 'pill',
        name: pill.name || '未知焰丹',
        description: pill.description || '',
        quality: pill.quality || 'common',
        grade: pill.grade || 1,
        effect: pill.effect || {}
      }

      gd.items.push(pillItem)
      await pool.query('UPDATE players SET game_data = $1 WHERE wallet = $2', [JSON.stringify(gd), wallet])

      // 记录日志
      await logAdminAction(adminWallet, 'GIVE_PILL', wallet, pill)

      res.json({ success: true, data: pillItem, message: '焰丹空投成功' })
    } catch (err) {
      logger.error('Admin give pill error:', err)
      res.status(500).json({ success: false, message: '服务器错误' })
    }
  })

  // ==================== 新增路由 ====================

  // 1. GET /dashboard - 仪表盘数据
  router.get('/dashboard', auth, adminAuth, async (req, res) => {
    try {
      const [totalPlayers, todayNew, totalRecharge, todayRecharge, vipDistribution] = await Promise.all([
        pool.query('SELECT count(*) as count FROM players'),
        pool.query("SELECT count(*) as count FROM players WHERE created_at > CURRENT_DATE"),
        pool.query('SELECT COALESCE(sum(amount),0) as sum FROM recharge_log'),
        pool.query("SELECT COALESCE(sum(amount),0) as sum FROM recharge_log WHERE created_at > CURRENT_DATE"),
        pool.query('SELECT vip_level, count(*) as count FROM players GROUP BY vip_level ORDER BY vip_level')
      ])

      res.json({
        success: true,
        data: {
          total_players: parseInt(totalPlayers.rows[0].count),
          today_new: parseInt(todayNew.rows[0].count),
          total_recharge: parseInt(totalRecharge.rows[0].sum),
          today_recharge: parseInt(todayRecharge.rows[0].sum),
          vip_distribution: vipDistribution.rows
        }
      })
    } catch (err) {
      logger.error('Admin dashboard error:', err)
      res.status(500).json({ success: false, message: '服务器错误' })
    }
  })

  // 2. GET /recharges - 充值记录列表
  router.get('/recharges', auth, adminAuth, async (req, res) => {
    try {
      const { page = 1, limit = 20, wallet, from, to } = req.query
      const offset = (page - 1) * limit

      let whereClause = ''
      const params = []
      let idx = 1

      if (wallet) {
        whereClause += `WHERE wallet ILIKE $${idx}`
        params.push(`%${wallet}%`)
        idx++
      }

      if (from) {
        whereClause += whereClause ? ' AND ' : 'WHERE '
        whereClause += `created_at >= $${idx}`
        params.push(from)
        idx++
      }

      if (to) {
        whereClause += whereClause ? ' AND ' : 'WHERE '
        whereClause += `created_at <= $${idx}`
        params.push(to + ' 23:59:59')
        idx++
      }

      const countResult = await pool.query(`SELECT count(*) FROM recharge_log ${whereClause}`, params)
      const total = parseInt(countResult.rows[0].count)

      params.push(limit, offset)
      const result = await pool.query(
        `SELECT * FROM recharge_log ${whereClause} ORDER BY created_at DESC LIMIT $${idx} OFFSET $${idx + 1}`,
        params
      )

      res.json({ success: true, data: { recharges: result.rows, total, page: Number(page), limit: Number(limit) } })
    } catch (err) {
      logger.error('Admin recharges error:', err)
      res.status(500).json({ success: false, message: '服务器错误' })
    }
  })

  // 3. GET/POST/PUT/:id/DELETE/:id /announcements - 公告管理
  router.get('/announcements', auth, adminAuth, async (req, res) => {
    try {
      const result = await pool.query('SELECT * FROM announcements ORDER BY created_at DESC')
      res.json({ success: true, data: result.rows })
    } catch (err) {
      logger.error('Admin get announcements error:', err)
      res.status(500).json({ success: false, message: '服务器错误' })
    }
  })

  router.post('/announcements', auth, adminAuth, async (req, res) => {
    try {
      const { title, content } = req.body
      const adminWallet = req.user.wallet
      
      if (!title || !content) {
        return res.status(400).json({ success: false, message: '标题和内容不能为空' })
      }

      const result = await pool.query(
        'INSERT INTO announcements (title, content, created_at, updated_at) VALUES ($1, $2, NOW(), NOW()) RETURNING *',
        [title, content]
      )

      await logAdminAction(adminWallet, 'CREATE_ANNOUNCEMENT', null, { title, content })
      res.json({ success: true, data: result.rows[0] })
    } catch (err) {
      logger.error('Admin create announcement error:', err)
      res.status(500).json({ success: false, message: '服务器错误' })
    }
  })

  router.put('/announcements/:id', auth, adminAuth, async (req, res) => {
    try {
      const { id } = req.params
      const { title, content } = req.body
      const adminWallet = req.user.wallet

      const result = await pool.query(
        'UPDATE announcements SET title = $1, content = $2, updated_at = NOW() WHERE id = $3 RETURNING *',
        [title, content, id]
      )

      if (result.rows.length === 0) {
        return res.status(404).json({ success: false, message: '公告不存在' })
      }

      await logAdminAction(adminWallet, 'UPDATE_ANNOUNCEMENT', id, { title, content })
      res.json({ success: true, data: result.rows[0] })
    } catch (err) {
      logger.error('Admin update announcement error:', err)
      res.status(500).json({ success: false, message: '服务器错误' })
    }
  })

  router.delete('/announcements/:id', auth, adminAuth, async (req, res) => {
    try {
      const { id } = req.params
      const adminWallet = req.user.wallet

      const result = await pool.query('DELETE FROM announcements WHERE id = $1 RETURNING *', [id])

      if (result.rows.length === 0) {
        return res.status(404).json({ success: false, message: '公告不存在' })
      }

      await logAdminAction(adminWallet, 'DELETE_ANNOUNCEMENT', id, {})
      res.json({ success: true, message: '删除成功' })
    } catch (err) {
      logger.error('Admin delete announcement error:', err)
      res.status(500).json({ success: false, message: '服务器错误' })
    }
  })

  // 4. GET/DELETE/:id /sects - 宗门管理
  router.get('/sects', auth, adminAuth, async (req, res) => {
    try {
      const result = await pool.query(`
        SELECT s.*, 
               (SELECT count(*) FROM sect_members WHERE sect_id = s.id) as member_count
        FROM sects s ORDER BY s.id DESC
      `)
      res.json({ success: true, data: result.rows })
    } catch (err) {
      logger.error('Admin get sects error:', err)
      res.status(500).json({ success: false, message: '服务器错误' })
    }
  })

  router.delete('/sects/:id', auth, adminAuth, async (req, res) => {
    try {
      const { id } = req.params
      const adminWallet = req.user.wallet

      const sect = await pool.query('SELECT name FROM sects WHERE id = $1', [id])
      if (sect.rows.length === 0) {
        return res.status(404).json({ success: false, message: '宗门不存在' })
      }

      await pool.query('DELETE FROM sect_members WHERE sect_id = $1', [id])
      await pool.query('DELETE FROM sects WHERE id = $1', [id])

      await logAdminAction(adminWallet, 'DELETE_SECT', id, { name: sect.rows[0].name })
      res.json({ success: true, message: '宗门已解散' })
    } catch (err) {
      logger.error('Admin delete sect error:', err)
      res.status(500).json({ success: false, message: '服务器错误' })
    }
  })

  // 5. GET /economy - 经济统计
  router.get('/economy', auth, adminAuth, async (req, res) => {
    try {
      const [totalResult, avgResult, totalPlayers, richest] = await Promise.all([
        pool.query('SELECT COALESCE(SUM(spirit_stones), 0) as total FROM players'),
        pool.query('SELECT COALESCE(AVG(spirit_stones), 0) as avg FROM players'),
        pool.query('SELECT COUNT(*) as count FROM players'),
        pool.query('SELECT wallet, name, spirit_stones FROM players ORDER BY spirit_stones DESC LIMIT 10')
      ])

      // 计算中位数
      const medianResult = await pool.query(`
        SELECT percentile_cont(0.5) WITHIN GROUP (ORDER BY spirit_stones) as median 
        FROM players
      `)

      res.json({
        success: true,
        data: {
          totalStones: parseInt(totalResult.rows[0].total),
          avgStones: Math.round(parseFloat(avgResult.rows[0].avg)),
          medianStones: Math.round(parseFloat(medianResult.rows[0].median) || 0),
          totalPlayers: parseInt(totalPlayers.rows[0].count),
          richest: richest.rows
        }
      })
    } catch (err) {
      logger.error('Admin economy error:', err)
      res.status(500).json({ success: false, message: '服务器错误' })
    }
  })

  // 6. GET /leaderboard/:type - 排行榜
  router.get('/leaderboard/:type', auth, adminAuth, async (req, res) => {
    try {
      const { type } = req.params
      let orderBy

      switch (type) {
        case 'power':
          orderBy = 'combat_power DESC'
          break
        case 'level':
          orderBy = 'level DESC, combat_power DESC'
          break
        case 'stones':
          orderBy = 'spirit_stones DESC'
          break
        case 'recharge':
          orderBy = 'total_recharge DESC'
          break
        default:
          orderBy = 'combat_power DESC'
      }

      const result = await pool.query(
        `SELECT wallet, name, level, realm, combat_power, spirit_stones, vip_level, total_recharge 
         FROM players ORDER BY ${orderBy} LIMIT 50`
      )

      res.json({ success: true, data: result.rows })
    } catch (err) {
      logger.error('Admin leaderboard error:', err)
      res.status(500).json({ success: false, message: '服务器错误' })
    }
  })

  // 7. GET/DELETE/:id /auction/:view - 拍卖行管理
  router.get('/auction/:view', auth, adminAuth, async (req, res) => {
    try {
      const { view } = req.params
      let result

      if (view === 'active') {
        result = await pool.query(`
          SELECT al.*, p.name as seller_name 
          FROM auction_listings al 
          LEFT JOIN players p ON al.seller_wallet = p.wallet 
          WHERE al.status = 'active' 
          ORDER BY al.created_at DESC
        `)
      } else if (view === 'history') {
        result = await pool.query(`
          SELECT ah.*, s.name as seller_name, b.name as buyer_name 
          FROM auction_history ah 
          LEFT JOIN players s ON ah.seller_wallet = s.wallet 
          LEFT JOIN players b ON ah.buyer_wallet = b.wallet 
          ORDER BY ah.sold_at DESC 
          LIMIT 100
        `)
      } else {
        return res.status(400).json({ success: false, message: '无效的视图类型' })
      }

      res.json({ success: true, data: result.rows })
    } catch (err) {
      logger.error('Admin auction error:', err)
      res.status(500).json({ success: false, message: '服务器错误' })
    }
  })

  router.delete('/auction/:view/:id', auth, adminAuth, async (req, res) => {
    try {
      const { view, id } = req.params
      const adminWallet = req.user.wallet

      if (view === 'active') {
        const listing = await pool.query('SELECT * FROM auction_listings WHERE id = $1', [id])
        if (listing.rows.length === 0) {
          return res.status(404).json({ success: false, message: '拍卖不存在' })
        }

        // 如果有出价，退还
        if (listing.rows[0].current_bidder && listing.rows[0].current_bid > 0) {
          const bidder = listing.rows[0].current_bidder
          const bid = listing.rows[0].current_bid
          
          const player = await pool.query('SELECT game_data FROM players WHERE wallet = $1', [bidder])
          if (player.rows.length > 0) {
            let gd = typeof player.rows[0].game_data === 'string' ? 
              JSON.parse(player.rows[0].game_data) : player.rows[0].game_data
            gd.spiritStones = (gd.spiritStones || 0) + bid
            await pool.query(
              'UPDATE players SET spirit_stones = spirit_stones + $1, game_data = $2 WHERE wallet = $3',
              [bid, JSON.stringify(gd), bidder]
            )
          }
        }

        // 物品退回卖家
        const seller = listing.rows[0].seller_wallet
        const item = listing.rows[0].item_data
        const player = await pool.query('SELECT game_data FROM players WHERE wallet = $1', [seller])
        if (player.rows.length > 0) {
          let gd = typeof player.rows[0].game_data === 'string' ? 
            JSON.parse(player.rows[0].game_data) : player.rows[0].game_data
          if (!gd.items) gd.items = []
          gd.items.push(item)
          await pool.query('UPDATE players SET game_data = $1 WHERE wallet = $2', [JSON.stringify(gd), seller])
        }

        await pool.query("UPDATE auction_listings SET status = 'cancelled' WHERE id = $1", [id])
        await logAdminAction(adminWallet, 'CANCEL_AUCTION', id, { listing: listing.rows[0] })
      }

      res.json({ success: true, message: '操作成功' })
    } catch (err) {
      logger.error('Admin delete auction error:', err)
      res.status(500).json({ success: false, message: '服务器错误' })
    }
  })

  // 8. GET /online - 在线玩家
  router.get('/online', auth, adminAuth, async (req, res) => {
    try {
      // 获取15分钟内有活动的玩家
      const activeResult = await pool.query(`
        SELECT DISTINCT ON (wallet) wallet, created_at 
        FROM login_logs 
        WHERE created_at > NOW() - INTERVAL '15 minutes'
        ORDER BY wallet, created_at DESC
      `)

      const activePlayers = await pool.query(`
        SELECT p.wallet, p.name, p.level, p.realm, p.combat_power 
        FROM players p 
        WHERE p.wallet = ANY($1)
      `, [activeResult.rows.map(r => r.wallet)])

      // 获取WebSocket在线数
      const onlineCount = activeResult.rows.length

      res.json({
        success: true,
        data: {
          onlineCount,
          activeCount: activePlayers.rows.length,
          activePlayers: activePlayers.rows
        }
      })
    } catch (err) {
      logger.error('Admin online error:', err)
      res.status(500).json({ success: false, message: '服务器错误' })
    }
  })

  // 9. GET/PUT /shop-config - 商店配置
  router.get('/shop-config', auth, adminAuth, async (req, res) => {
    try {
      const result = await pool.query("SELECT value FROM settings WHERE key = 'shop_config'")
      if (result.rows.length === 0) {
        return res.json({ success: true, data: { items: [], categories: [] } })
      }
      res.json({ success: true, data: result.rows[0].value })
    } catch (err) {
      logger.error('Admin get shop config error:', err)
      res.status(500).json({ success: false, message: '服务器错误' })
    }
  })

  router.put('/shop-config', auth, adminAuth, async (req, res) => {
    try {
      const { config } = req.body
      const adminWallet = req.user.wallet

      await pool.query(`
        INSERT INTO settings (key, value, updated_at) 
        VALUES ('shop_config', $1, NOW()) 
        ON CONFLICT (key) DO UPDATE SET value = $1, updated_at = NOW()
      `, [JSON.stringify(config)])

      await logAdminAction(adminWallet, 'UPDATE_SHOP_CONFIG', null, config)
      res.json({ success: true, message: '商店配置已更新' })
    } catch (err) {
      logger.error('Admin update shop config error:', err)
      res.status(500).json({ success: false, message: '服务器错误' })
    }
  })

  // 10. GET/PUT /gacha-config - 抽卡配置
  router.get('/gacha-config', auth, adminAuth, async (req, res) => {
    try {
      const result = await pool.query("SELECT value FROM settings WHERE key = 'gacha_config'")
      if (result.rows.length === 0) {
        return res.json({ 
          success: true, 
          data: { 
            probabilities: { common: 60, rare: 30, epic: 9, legendary: 1 },
            costs: { single: 100, ten: 900 }
          } 
        })
      }
      res.json({ success: true, data: result.rows[0].value })
    } catch (err) {
      logger.error('Admin get gacha config error:', err)
      res.status(500).json({ success: false, message: '服务器错误' })
    }
  })

  router.put('/gacha-config', auth, adminAuth, async (req, res) => {
    try {
      const { config } = req.body
      const adminWallet = req.user.wallet

      await pool.query(`
        INSERT INTO settings (key, value, updated_at) 
        VALUES ('gacha_config', $1, NOW()) 
        ON CONFLICT (key) DO UPDATE SET value = $1, updated_at = NOW()
      `, [JSON.stringify(config)])

      await logAdminAction(adminWallet, 'UPDATE_GACHA_CONFIG', null, config)
      res.json({ success: true, message: '抽卡配置已更新' })
    } catch (err) {
      logger.error('Admin update gacha config error:', err)
      res.status(500).json({ success: false, message: '服务器错误' })
    }
  })

  // 11. GET /logs - 管理员日志
  router.get('/logs', auth, adminAuth, async (req, res) => {
    try {
      const { page = 1, limit = 20 } = req.query
      const offset = (page - 1) * limit

      const countResult = await pool.query('SELECT count(*) FROM admin_logs')
      const total = parseInt(countResult.rows[0].count)

      const result = await pool.query(
        `SELECT * FROM admin_logs ORDER BY created_at DESC LIMIT $1 OFFSET $2`,
        [limit, offset]
      )

      res.json({ success: true, data: { logs: result.rows, total, page: Number(page), limit: Number(limit) } })
    } catch (err) {
      logger.error('Admin logs error:', err)
      res.status(500).json({ success: false, message: '服务器错误' })
    }
  })

  // 12. GET/PUT /settings - 游戏全局设置
  router.get('/settings', auth, adminAuth, async (req, res) => {
    try {
      const result = await pool.query("SELECT key, value FROM settings WHERE key IN ('vip_config', 'monthly_card_price', 'game_config')")
      const settings = {}
      result.rows.forEach(row => {
        settings[row.key] = row.value
      })
      res.json({ success: true, data: settings })
    } catch (err) {
      logger.error('Admin get settings error:', err)
      res.status(500).json({ success: false, message: '服务器错误' })
    }
  })

  router.put('/settings', auth, adminAuth, async (req, res) => {
    try {
      const { key, value } = req.body
      const adminWallet = req.user.wallet

      if (!key) {
        return res.status(400).json({ success: false, message: '设置键名不能为空' })
      }

      await pool.query(`
        INSERT INTO settings (key, value, updated_at) 
        VALUES ($1, $2, NOW()) 
        ON CONFLICT (key) DO UPDATE SET value = $2, updated_at = NOW()
      `, [key, JSON.stringify(value)])

      await logAdminAction(adminWallet, 'UPDATE_SETTINGS', key, value)
      res.json({ success: true, message: '设置已更新' })
    } catch (err) {
      logger.error('Admin update settings error:', err)
      res.status(500).json({ success: false, message: '服务器错误' })
    }
  })

  // 13. POST /players/:wallet/ban, POST /players/:wallet/unban - 封禁/解封
  router.post('/players/:wallet/ban', auth, adminAuth, async (req, res) => {
    try {
      const { wallet } = req.params
      const { reason } = req.body
      const adminWallet = req.user.wallet

      const result = await pool.query(
        'UPDATE players SET banned = true WHERE wallet = $1 RETURNING *',
        [wallet]
      )

      if (result.rows.length === 0) {
        return res.status(404).json({ success: false, message: '玩家不存在' })
      }

      await logAdminAction(adminWallet, 'BAN_PLAYER', wallet, { reason })
      res.json({ success: true, message: '玩家已封禁' })
    } catch (err) {
      logger.error('Admin ban player error:', err)
      res.status(500).json({ success: false, message: '服务器错误' })
    }
  })

  router.post('/players/:wallet/unban', auth, adminAuth, async (req, res) => {
    try {
      const { wallet } = req.params
      const adminWallet = req.user.wallet

      const result = await pool.query(
        'UPDATE players SET banned = false WHERE wallet = $1 RETURNING *',
        [wallet]
      )

      if (result.rows.length === 0) {
        return res.status(404).json({ success: false, message: '玩家不存在' })
      }

      await logAdminAction(adminWallet, 'UNBAN_PLAYER', wallet, {})
      res.json({ success: true, message: '玩家已解封' })
    } catch (err) {
      logger.error('Admin unban player error:', err)
      res.status(500).json({ success: false, message: '服务器错误' })
    }
  })

  // 14. POST /players/:wallet/adjust-stones - 调整焰晶
  router.post('/players/:wallet/adjust-stones', auth, adminAuth, async (req, res) => {
    try {
      const { wallet } = req.params
      const { amount, reason } = req.body
      const adminWallet = req.user.wallet

      if (amount === undefined || amount === null) {
        return res.status(400).json({ success: false, message: '金额不能为空' })
      }

      const player = await pool.query('SELECT game_data, spirit_stones FROM players WHERE wallet = $1', [wallet])
      if (player.rows.length === 0) {
        return res.status(404).json({ success: false, message: '玩家不存在' })
      }

      let gd = typeof player.rows[0].game_data === 'string' ? 
        JSON.parse(player.rows[0].game_data) : player.rows[0].game_data

      const newStones = (gd.spiritStones || 0) + parseInt(amount)
      if (newStones < 0) {
        return res.status(400).json({ success: false, message: '焰晶不能为负数' })
      }

      gd.spiritStones = newStones

      await pool.query(
        'UPDATE players SET spirit_stones = $1, game_data = $2 WHERE wallet = $3',
        [newStones, JSON.stringify(gd), wallet]
      )

      await logAdminAction(adminWallet, 'ADJUST_STONES', wallet, { amount, newTotal: newStones, reason })
      res.json({ success: true, message: `焰晶已${amount >= 0 ? '增加' : '扣除'} ${Math.abs(amount)}`, data: { spirit_stones: newStones } })
    } catch (err) {
      logger.error('Admin adjust stones error:', err)
      res.status(500).json({ success: false, message: '服务器错误' })
    }
  })

  // 15. PUT /players/:wallet/level - 修改等级和境界
  router.put('/players/:wallet/level', auth, adminAuth, async (req, res) => {
    try {
      const { wallet } = req.params
      const { level, realm } = req.body
      const adminWallet = req.user.wallet

      const player = await pool.query('SELECT game_data FROM players WHERE wallet = $1', [wallet])
      if (player.rows.length === 0) {
        return res.status(404).json({ success: false, message: '玩家不存在' })
      }

      let gd = typeof player.rows[0].game_data === 'string' ? 
        JSON.parse(player.rows[0].game_data) : player.rows[0].game_data

      const updates = []
      const values = []
      let idx = 1

      if (level !== undefined) {
        updates.push(`level = $${idx}`)
        values.push(level)
        gd.level = level
        idx++
      }

      if (realm !== undefined) {
        updates.push(`realm = $${idx}`)
        values.push(realm)
        gd.realm = realm
        idx++
      }

      if (updates.length > 0) {
        values.push(wallet)
        await pool.query(
          `UPDATE players SET ${updates.join(', ')}, game_data = $${idx} WHERE wallet = $${idx + 1}`,
          [...values, JSON.stringify(gd), wallet]
        )
      }

      await logAdminAction(adminWallet, 'UPDATE_PLAYER_LEVEL', wallet, { level, realm })
      res.json({ success: true, message: '玩家等级/境界已更新' })
    } catch (err) {
      logger.error('Admin update player level error:', err)
      res.status(500).json({ success: false, message: '服务器错误' })
    }
  })

  // 16. PUT /players/:wallet/vip - 修改VIP等级
  router.put('/players/:wallet/vip', auth, adminAuth, async (req, res) => {
    try {
      const { wallet } = req.params
      const { vip_level } = req.body
      const adminWallet = req.user.wallet

      if (vip_level === undefined || vip_level < 0) {
        return res.status(400).json({ success: false, message: 'VIP等级无效' })
      }

      const result = await pool.query(
        'UPDATE players SET vip_level = $1 WHERE wallet = $2 RETURNING *',
        [vip_level, wallet]
      )

      if (result.rows.length === 0) {
        return res.status(404).json({ success: false, message: '玩家不存在' })
      }

      await logAdminAction(adminWallet, 'UPDATE_VIP', wallet, { vip_level })
      res.json({ success: true, message: 'VIP等级已更新' })
    } catch (err) {
      logger.error('Admin update vip error:', err)
      res.status(500).json({ success: false, message: '服务器错误' })
    }
  })

  // 17. PUT /players/:wallet/stones - 调整焰晶（同 adjust-stones）
  router.put('/players/:wallet/stones', auth, adminAuth, async (req, res) => {
    try {
      const { wallet } = req.params
      const { amount, reason } = req.body
      const adminWallet = req.user.wallet

      if (amount === undefined || amount === null) {
        return res.status(400).json({ success: false, message: '金额不能为空' })
      }

      const player = await pool.query('SELECT game_data, spirit_stones FROM players WHERE wallet = $1', [wallet])
      if (player.rows.length === 0) {
        return res.status(404).json({ success: false, message: '玩家不存在' })
      }

      let gd = typeof player.rows[0].game_data === 'string' ? 
        JSON.parse(player.rows[0].game_data) : player.rows[0].game_data

      const newStones = parseInt(amount)
      if (newStones < 0) {
        return res.status(400).json({ success: false, message: '焰晶不能为负数' })
      }

      gd.spiritStones = newStones

      await pool.query(
        'UPDATE players SET spirit_stones = $1, game_data = $2 WHERE wallet = $3',
        [newStones, JSON.stringify(gd), wallet]
      )

      await logAdminAction(adminWallet, 'SET_STONES', wallet, { amount: newStones, reason })
      res.json({ success: true, message: '焰晶已设置', data: { spirit_stones: newStones } })
    } catch (err) {
      logger.error('Admin set stones error:', err)
      res.status(500).json({ success: false, message: '服务器错误' })
    }
  })

  return router
}
