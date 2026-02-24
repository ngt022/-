import express from 'express'
const router = express.Router()

export default (pool, auth) => {
  router.post('/start', auth, async (req, res) => {
    try {
      const wallet = req.user.wallet
      const today = new Date().toISOString().slice(0, 10)
      const row = await pool.query('SELECT game_data FROM players WHERE wallet = $1', [wallet])
      const gd = row.rows[0]?.game_data || {}
      const mg = gd.matchGame || {}
      if (mg.lastDate === today && (mg.playCount || 0) >= 3) {
        return res.json({ success: false, message: '今日次数已用完（3/3）' })
      }
      const gameToken = Date.now().toString(36) + Math.random().toString(36).slice(2, 8)
      const newMg = { ...mg, currentToken: gameToken, lastDate: today, playCount: mg.lastDate === today ? (mg.playCount || 0) : 0 }
      await pool.query("UPDATE players SET game_data = jsonb_set(COALESCE(game_data, '{}'), '{matchGame}', $1::jsonb) WHERE wallet = $2", [JSON.stringify(newMg), wallet])
      res.json({ success: true, gameToken, remainingPlays: 3 - newMg.playCount })
    } catch (e) { res.status(500).json({ success: false, message: e.message }) }
  })

  router.post('/submit', auth, async (req, res) => {
    try {
      const wallet = req.user.wallet
      const { gameToken, score } = req.body
      const today = new Date().toISOString().slice(0, 10)
      const row = await pool.query('SELECT game_data FROM players WHERE wallet = $1', [wallet])
      const gd = row.rows[0]?.game_data || {}
      const mg = gd.matchGame || {}
      if (mg.currentToken !== gameToken) return res.json({ success: false, message: '无效的游戏会话' })
      const maxScore = Math.min(score, 10000)
      let reward = maxScore >= 2000 ? 500 : maxScore >= 1500 ? 300 : maxScore >= 1000 ? 200 : maxScore >= 500 ? 100 : 50
      await pool.query("UPDATE players SET game_data = jsonb_set(game_data, '{spiritStones}', to_jsonb((COALESCE((game_data->>'spiritStones')::int, 0) + $1)::int)) WHERE wallet = $2", [reward, wallet])
      const newCount = (mg.lastDate === today ? (mg.playCount || 0) : 0) + 1
      await pool.query("UPDATE players SET game_data = jsonb_set(COALESCE(game_data, '{}'), '{matchGame}', $1::jsonb) WHERE wallet = $2", [JSON.stringify({ lastDate: today, playCount: newCount, currentToken: null, bestScore: Math.max(mg.bestScore || 0, maxScore) }), wallet])
      res.json({ success: true, score: maxScore, reward, remainingPlays: 3 - newCount, bestScore: Math.max(mg.bestScore || 0, maxScore) })
    } catch (e) { res.status(500).json({ success: false, message: e.message }) }
  })

  router.get('/status', auth, async (req, res) => {
    try {
      const wallet = req.user.wallet
      const today = new Date().toISOString().slice(0, 10)
      const row = await pool.query('SELECT game_data FROM players WHERE wallet = $1', [wallet])
      const gd = row.rows[0]?.game_data || {}
      const mg = gd.matchGame || {}
      const playCount = mg.lastDate === today ? (mg.playCount || 0) : 0
      res.json({ success: true, playCount, remainingPlays: 3 - playCount, bestScore: mg.bestScore || 0 })
    } catch (e) { res.status(500).json({ success: false, message: e.message }) }
  })

  return router
}
