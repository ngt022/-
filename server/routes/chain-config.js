import express from 'express'
const router = express.Router()

export default (pool, auth) => {
  // GET /api/admin/chain-config - 获取链和合约配置
  router.get('/chain-config', auth, async (req, res) => {
    try {
      const chain = await pool.query("SELECT value FROM settings WHERE key = 'chain_config'")
      const recharge = await pool.query("SELECT value FROM settings WHERE key = 'recharge_config'")
      res.json({
        success: true,
        chainConfig: chain.rows[0]?.value || {},
        rechargeConfig: recharge.rows[0]?.value || {}
      })
    } catch (e) {
      res.status(500).json({ error: e.message })
    }
  })

  // POST /api/admin/chain-config - 更新链配置
  router.post('/chain-config', auth, async (req, res) => {
    try {
      const { chainId, chainName, rpcUrl, symbol, decimals, vaultContract, explorerUrl } = req.body
      const config = { chainId, chainName, rpcUrl, symbol, decimals: decimals || 18, vaultContract: vaultContract || '', explorerUrl: explorerUrl || '' }
      await pool.query(
        "INSERT INTO settings (key, value) VALUES ('chain_config', $1::jsonb) ON CONFLICT (key) DO UPDATE SET value = $1::jsonb, updated_at = NOW()",
        [JSON.stringify(config)]
      )
      res.json({ success: true, config })
    } catch (e) {
      res.status(500).json({ error: e.message })
    }
  })

  // POST /api/admin/recharge-config - 更新充值配置
  router.post('/recharge-config', auth, async (req, res) => {
    try {
      const { enabled, ratePerRoon, minAmount, confirmations } = req.body
      const config = {
        enabled: !!enabled,
        ratePerRoon: Number(ratePerRoon) || 10000,
        minAmount: String(minAmount || '0.01'),
        confirmations: Number(confirmations) || 3
      }
      await pool.query(
        "INSERT INTO settings (key, value) VALUES ('recharge_config', $1::jsonb) ON CONFLICT (key) DO UPDATE SET value = $1::jsonb, updated_at = NOW()",
        [JSON.stringify(config)]
      )
      res.json({ success: true, config })
    } catch (e) {
      res.status(500).json({ error: e.message })
    }
  })

  // GET /api/admin/recharge-logs - 充值记录
  router.get('/recharge-logs', auth, async (req, res) => {
    try {
      const r = await pool.query(
        "SELECT * FROM recharge_log ORDER BY created_at DESC LIMIT 50"
      )
      res.json({ success: true, logs: r.rows })
    } catch (e) {
      res.status(500).json({ error: e.message })
    }
  })

  return router
}
