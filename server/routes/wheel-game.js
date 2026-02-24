import express from 'express'
const router = express.Router()

const SECTORS = [
  { label: '100焰晶', type: 'stones', value: 100, weight: 25 },
  { label: '200焰晶', type: 'stones', value: 200, weight: 20 },
  { label: '500焰晶', type: 'stones', value: 500, weight: 12 },
  { label: '1000焰晶', type: 'stones', value: 1000, weight: 3 },
  { label: '焰灵x1000', type: 'spirit', value: 1000, weight: 15 },
  { label: '随机丹药x1', type: 'pill', value: 1, weight: 5 },
  { label: '50焰晶', type: 'stones', value: 50, weight: 30 },
  { label: '150焰晶', type: 'stones', value: 150, weight: 20 }
]

function weightedRandom() {
  const totalWeight = SECTORS.reduce((s, sec) => s + sec.weight, 0)
  let r = Math.random() * totalWeight
  for (let i = 0; i < SECTORS.length; i++) {
    r -= SECTORS[i].weight
    if (r <= 0) return i
  }
  return 0
}

export default (pool, auth) => {
  router.post('/spin', auth, async (req, res) => {
    try {
      const wallet = req.user.wallet
      const today = new Date().toISOString().slice(0, 10)
      const row = await pool.query('SELECT game_data FROM players WHERE wallet = $1', [wallet])
      const gd = row.rows[0]?.game_data || {}
      const mg = gd.wheelGame || {}
      const spinCount = mg.lastDate === today ? (mg.spinCount || 0) : 0
      if (spinCount >= 5) return res.json({ success: false, message: '今日转盘次数已用完（5/5）' })
      const isFree = spinCount === 0
      if (!isFree) {
        const stones = Number(gd.spiritStones) || 0
        if (stones < 200) return res.json({ success: false, message: '焰晶不足（需要200）' })
        await pool.query("UPDATE players SET game_data = jsonb_set(game_data, '{spiritStones}', to_jsonb((COALESCE((game_data->>'spiritStones')::int, 0) - 200)::int)) WHERE wallet = $1", [wallet])
      }
      const sectorIndex = weightedRandom()
      const sector = SECTORS[sectorIndex]
      if (sector.type === 'stones') {
        await pool.query("UPDATE players SET game_data = jsonb_set(game_data, '{spiritStones}', to_jsonb((COALESCE((game_data->>'spiritStones')::int, 0) + $1)::int)) WHERE wallet = $2", [sector.value, wallet])
      } else if (sector.type === 'spirit') {
        await pool.query("UPDATE players SET game_data = jsonb_set(game_data, '{spirit}', to_jsonb((COALESCE((game_data->>'spirit')::float, 0) + $1)::float)) WHERE wallet = $2", [sector.value, wallet])
      }
      const newCount = spinCount + 1
      await pool.query("UPDATE players SET game_data = jsonb_set(COALESCE(game_data, '{}'), '{wheelGame}', $1::jsonb) WHERE wallet = $2", [JSON.stringify({ lastDate: today, spinCount: newCount }), wallet])
      // 追踪小游戏分数
      try { if (req.app.monthlyRankings) await req.app.monthlyRankings.trackMinigameScore(wallet || req.wallet, score || maxScore || 0); } catch(e) {}
      res.json({ success: true, sectorIndex, reward: sector, remainingSpins: 5 - newCount, isFree, cost: isFree ? 0 : 200 })
    } catch (e) { res.status(500).json({ success: false, message: e.message }) }
  })

  router.get('/status', auth, async (req, res) => {
    try {
      const wallet = req.user.wallet
      const today = new Date().toISOString().slice(0, 10)
      const row = await pool.query('SELECT game_data FROM players WHERE wallet = $1', [wallet])
      const gd = row.rows[0]?.game_data || {}
      const mg = gd.wheelGame || {}
      const spinCount = mg.lastDate === today ? (mg.spinCount || 0) : 0
      res.json({ success: true, spinCount, remainingSpins: 5 - spinCount, isFreeAvailable: spinCount === 0 })
    } catch (e) { res.status(500).json({ success: false, message: e.message }) }
  })

  return router
}
