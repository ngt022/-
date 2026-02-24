const express = require('express')
const router = express.Router()

// 从 index.js 获取 pool 和 auth — 这个文件会被 index.js require 并 use
// 需要在 module.exports 时传入 pool 和 auth
module.exports = (pool, auth) => {

  // 开始试炼 — 检查今日次数
  router.post('/start', auth, async (req, res) => {
    try {
      const wallet = req.user.wallet
      const today = new Date().toISOString().slice(0, 10)
      const row = await pool.query('SELECT game_data FROM players WHERE wallet = $1', [wallet])
      const gd = row.rows[0]?.game_data || {}
      const mgData = gd.minigame || {}
      
      if (mgData.lastDate === today && (mgData.playCount || 0) >= 3) {
        return res.json({ success: false, message: '今日试炼次数已用完（3/3）' })
      }
      
      // 生成一局游戏的 token（防作弊）
      const gameToken = Date.now().toString(36) + Math.random().toString(36).slice(2, 8)
      
      await pool.query(
        "UPDATE players SET game_data = jsonb_set(COALESCE(game_data, '{}'), '{minigame}', $1::jsonb) WHERE wallet = $2",
        [JSON.stringify({ ...mgData, currentToken: gameToken, lastDate: today, playCount: mgData.lastDate === today ? (mgData.playCount || 0) : 0 }), wallet]
      )
      
      res.json({ success: true, gameToken, remainingPlays: 3 - (mgData.lastDate === today ? (mgData.playCount || 0) : 0) })
    } catch (e) {
      res.status(500).json({ success: false, message: e.message })
    }
  })

  // 提交结果
  router.post('/submit', auth, async (req, res) => {
    try {
      const wallet = req.user.wallet
      const { gameToken, score, hits, totalRunes } = req.body
      const today = new Date().toISOString().slice(0, 10)
      
      const row = await pool.query('SELECT game_data FROM players WHERE wallet = $1', [wallet])
      const gd = row.rows[0]?.game_data || {}
      const mgData = gd.minigame || {}
      
      // 验证 token
      if (mgData.currentToken !== gameToken) {
        return res.json({ success: false, message: '无效的游戏会话' })
      }
      
      // 防作弊：分数上限
      const maxScore = Math.min(score, 10000)
      
      // 根据分数计算奖励
      let reward = 0
      if (maxScore >= 8000) reward = 500
      else if (maxScore >= 5000) reward = 300
      else if (maxScore >= 3000) reward = 200
      else if (maxScore >= 1000) reward = 100
      else reward = 50
      
      // 发放焰晶
      await pool.query(
        "UPDATE players SET game_data = jsonb_set(game_data, '{spiritStones}', to_jsonb((COALESCE((game_data->>'spiritStones')::int, 0) + $1)::int)) WHERE wallet = $2",
        [reward, wallet]
      )
      
      // 更新次数
      const newCount = (mgData.lastDate === today ? (mgData.playCount || 0) : 0) + 1
      await pool.query(
        "UPDATE players SET game_data = jsonb_set(COALESCE(game_data, '{}'), '{minigame}', $1::jsonb) WHERE wallet = $2",
        [JSON.stringify({ lastDate: today, playCount: newCount, currentToken: null, bestScore: Math.max(mgData.bestScore || 0, maxScore) }), wallet]
      )
      
      res.json({ success: true, score: maxScore, reward, remainingPlays: 3 - newCount, bestScore: Math.max(mgData.bestScore || 0, maxScore) })
    } catch (e) {
      res.status(500).json({ success: false, message: e.message })
    }
  })

  // 查询状态
  router.get('/status', auth, async (req, res) => {
    try {
      const wallet = req.user.wallet
      const today = new Date().toISOString().slice(0, 10)
      const row = await pool.query('SELECT game_data FROM players WHERE wallet = $1', [wallet])
      const gd = row.rows[0]?.game_data || {}
      const mgData = gd.minigame || {}
      const playCount = mgData.lastDate === today ? (mgData.playCount || 0) : 0
      res.json({ success: true, playCount, remainingPlays: 3 - playCount, bestScore: mgData.bestScore || 0 })
    } catch (e) {
      res.status(500).json({ success: false, message: e.message })
    }
  })

  return router
}
