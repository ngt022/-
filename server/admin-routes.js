// === Admin Routes Module ===
// 导入到主文件后调用 registerAdminRoutes(app, pool, auth, adminAuth)

// 初始化必要的表
async function initAdminTables(pool) {
  // 表已通过 postgres 用户手动创建，这里只做安全检查
  try {
    await pool.query('SELECT 1 FROM admin_logs LIMIT 0');
    await pool.query('SELECT 1 FROM settings LIMIT 0');
    await pool.query('SELECT banned FROM players LIMIT 0');
  } catch (e) {
    console.error('Admin tables check failed:', e.message);
  }
}

// 记录操作日志
async function logAction(pool, adminWallet, action, target, detail = {}) {
  await pool.query(
    'INSERT INTO admin_logs (admin_wallet, action, target, detail) VALUES ($1,$2,$3,$4)',
    [adminWallet, action, target, JSON.stringify(detail)]
  );
}

export default async function registerAdminRoutes(app, pool, auth, adminAuth) {
  await initAdminTables(pool);

  // ========== 1. 仪表盘 Dashboard ==========
  app.get('/api/admin/dashboard', auth, adminAuth, async (req, res) => {
    try {
      const today = new Date().toISOString().split('T')[0];
      const [totalPlayers, newToday, totalRecharge, rechargeToday, totalStones, vipDist] = await Promise.all([
        pool.query('SELECT COUNT(*) FROM players'),
        pool.query('SELECT COUNT(*) FROM players WHERE created_at::date = $1', [today]),
        pool.query('SELECT COALESCE(SUM(amount),0) as total FROM recharge_log'),
        pool.query('SELECT COALESCE(SUM(amount),0) as total FROM recharge_log WHERE created_at::date = $1', [today]),
        pool.query('SELECT COALESCE(SUM(spirit_stones),0) as total FROM players'),
        pool.query('SELECT vip_level, COUNT(*) as count FROM players GROUP BY vip_level ORDER BY vip_level'),
      ]);
      res.json({
        totalPlayers: parseInt(totalPlayers.rows[0].count),
        newToday: parseInt(newToday.rows[0].count),
        totalRecharge: parseFloat(totalRecharge.rows[0].total),
        rechargeToday: parseFloat(rechargeToday.rows[0].total),
        totalSpiritStones: parseInt(totalStones.rows[0].total),
        vipDistribution: vipDist.rows.map(r => ({ level: r.vip_level, count: parseInt(r.count) })),
      });
    } catch (e) { res.status(500).json({ error: e.message }); }
  });

  // ========== 2. 玩家管理 ==========
  // GET /api/admin/players — 玩家列表
  app.get('/api/admin/players', auth, adminAuth, async (req, res) => {
    try {
      const { page = 1, limit = 20, search } = req.query;
      const offset = (Math.max(1, parseInt(page)) - 1) * parseInt(limit);
      const params = [];
      let where = '';
      if (search) {
        where = 'WHERE wallet ILIKE $1 OR name ILIKE $1';
        params.push(`%${search}%`);
      }
      const countQ = await pool.query(`SELECT COUNT(*) FROM players ${where}`, params);
      const dataQ = await pool.query(
        `SELECT id, wallet, name, level, realm, combat_power, vip_level, spirit_stones,
                total_recharge, banned, created_at, updated_at
         FROM players ${where}
         ORDER BY created_at DESC LIMIT $${params.length+1} OFFSET $${params.length+2}`,
        [...params, parseInt(limit), offset]
      );
      res.json({
        total: parseInt(countQ.rows[0].count),
        page: parseInt(page),
        limit: parseInt(limit),
        players: dataQ.rows,
      });
    } catch (e) { res.status(500).json({ error: e.message }); }
  });

  // GET /api/admin/players/:wallet — 玩家详情
  app.get('/api/admin/players/:wallet', auth, adminAuth, async (req, res) => {
    try {
      const result = await pool.query('SELECT * FROM players WHERE wallet = $1', [req.params.wallet.toLowerCase()]);
      if (!result.rows.length) return res.status(404).json({ error: '玩家不存在' });
      const p = result.rows[0];
      res.json({ player: p });
    } catch (e) { res.status(500).json({ error: e.message }); }
  });

  // PUT /api/admin/players/:wallet/ban — 封禁/解封
  app.put('/api/admin/players/:wallet/ban', auth, adminAuth, async (req, res) => {
    try {
      const { banned } = req.body;
      const wallet = req.params.wallet.toLowerCase();
      const result = await pool.query(
        'UPDATE players SET banned = $1, updated_at = NOW() WHERE wallet = $2 RETURNING wallet, banned',
        [!!banned, wallet]
      );
      if (!result.rows.length) return res.status(404).json({ error: '玩家不存在' });
      await logAction(pool, req.user.wallet, banned ? 'ban_player' : 'unban_player', wallet);
      res.json({ ok: true, wallet, banned: result.rows[0].banned });
    } catch (e) { res.status(500).json({ error: e.message }); }
  });

  // PUT /api/admin/players/:wallet/stones — 调整焰晶
  app.put('/api/admin/players/:wallet/stones', auth, adminAuth, async (req, res) => {
    try {
      const { amount, reason } = req.body;
      if (!amount || typeof amount !== 'number') return res.status(400).json({ error: 'amount 必须为数字' });
      const wallet = req.params.wallet.toLowerCase();
      const result = await pool.query(
        'UPDATE players SET spirit_stones = spirit_stones + $1, updated_at = NOW() WHERE wallet = $2 RETURNING wallet, spirit_stones',
        [amount, wallet]
      );
      if (!result.rows.length) return res.status(404).json({ error: '玩家不存在' });
      await logAction(pool, req.user.wallet, 'adjust_stones', wallet, { amount, reason: reason || '', newBalance: result.rows[0].spirit_stones });
      res.json({ ok: true, wallet, spiritStones: result.rows[0].spirit_stones });
    } catch (e) { res.status(500).json({ error: e.message }); }
  });

  // ========== 3. 充值记录 ==========
  app.get('/api/admin/recharges', auth, adminAuth, async (req, res) => {
    try {
      const { page = 1, limit = 20, wallet, startDate, endDate } = req.query;
      const offset = (Math.max(1, parseInt(page)) - 1) * parseInt(limit);
      const conditions = [];
      const params = [];
      let idx = 1;
      if (wallet) { conditions.push(`wallet ILIKE $${idx++}`); params.push(`%${wallet}%`); }
      if (startDate) { conditions.push(`created_at >= $${idx++}`); params.push(startDate); }
      if (endDate) { conditions.push(`created_at <= $${idx++}::date + interval '1 day'`); params.push(endDate); }
      const where = conditions.length ? 'WHERE ' + conditions.join(' AND ') : '';
      const countQ = await pool.query(`SELECT COUNT(*) FROM recharge_log ${where}`, params);
      const dataQ = await pool.query(
        `SELECT id, wallet, tx_hash, amount, spirit_stones, bonus_stones, created_at
         FROM recharge_log ${where}
         ORDER BY created_at DESC LIMIT $${idx++} OFFSET $${idx++}`,
        [...params, parseInt(limit), offset]
      );
      res.json({
        total: parseInt(countQ.rows[0].count),
        page: parseInt(page),
        limit: parseInt(limit),
        recharges: dataQ.rows,
      });
    } catch (e) { res.status(500).json({ error: e.message }); }
  });

  // ========== 4. 公告管理 ==========
  app.get('/api/admin/announcements', auth, adminAuth, async (req, res) => {
    try {
      const result = await pool.query('SELECT * FROM announcements ORDER BY sort_order ASC, created_at DESC');
      res.json({ announcements: result.rows });
    } catch (e) { res.status(500).json({ error: e.message }); }
  });

  app.post('/api/admin/announcements', auth, adminAuth, async (req, res) => {
    try {
      const { content, type, sort_order, active } = req.body;
      if (!content) return res.status(400).json({ error: '公告内容不能为空' });
      const result = await pool.query(
        'INSERT INTO announcements (content, type, sort_order, active) VALUES ($1,$2,$3,$4) RETURNING *',
        [content, type || 'notice', sort_order || 0, active !== false]
      );
      await logAction(pool, req.user.wallet, 'create_announcement', String(result.rows[0].id), { content });
      res.json({ announcement: result.rows[0] });
    } catch (e) { res.status(500).json({ error: e.message }); }
  });

  app.put('/api/admin/announcements/:id', auth, adminAuth, async (req, res) => {
    try {
      const { content, type, sort_order, active } = req.body;
      const result = await pool.query(
        `UPDATE announcements SET
          content=COALESCE($1,content), type=COALESCE($2,type),
          sort_order=COALESCE($3,sort_order), active=COALESCE($4,active),
          updated_at=NOW()
         WHERE id=$5 RETURNING *`,
        [content, type, sort_order, active, req.params.id]
      );
      if (!result.rows.length) return res.status(404).json({ error: '公告不存在' });
      await logAction(pool, req.user.wallet, 'update_announcement', req.params.id, { content, type, active });
      res.json({ announcement: result.rows[0] });
    } catch (e) { res.status(500).json({ error: e.message }); }
  });

  app.delete('/api/admin/announcements/:id', auth, adminAuth, async (req, res) => {
    try {
      const result = await pool.query('DELETE FROM announcements WHERE id=$1 RETURNING id', [req.params.id]);
      if (!result.rows.length) return res.status(404).json({ error: '公告不存在' });
      await logAction(pool, req.user.wallet, 'delete_announcement', req.params.id);
      res.json({ ok: true });
    } catch (e) { res.status(500).json({ error: e.message }); }
  });

  // ========== 5. 焰盟管理 ==========
  app.get('/api/admin/sects', auth, adminAuth, async (req, res) => {
    try {
      const result = await pool.query(
        `SELECT s.*, COUNT(sm.id) as member_count
         FROM sects s LEFT JOIN sect_members sm ON s.id = sm.sect_id
         GROUP BY s.id ORDER BY s.created_at DESC`
      );
      res.json({ sects: result.rows });
    } catch (e) { res.status(500).json({ error: e.message }); }
  });

  app.delete('/api/admin/sects/:id', auth, adminAuth, async (req, res) => {
    try {
      const sect = await pool.query('SELECT name FROM sects WHERE id=$1', [req.params.id]);
      if (!sect.rows.length) return res.status(404).json({ error: '焰盟不存在' });
      await pool.query('DELETE FROM sect_members WHERE sect_id=$1', [req.params.id]);
      await pool.query('DELETE FROM sects WHERE id=$1', [req.params.id]);
      await logAction(pool, req.user.wallet, 'disband_sect', req.params.id, { name: sect.rows[0].name });
      res.json({ ok: true });
    } catch (e) { res.status(500).json({ error: e.message }); }
  });

  // ========== 6. 系统设置 ==========
  app.get('/api/admin/settings', auth, adminAuth, async (req, res) => {
    try {
      const result = await pool.query('SELECT key, value FROM settings ORDER BY key');
      const settings = {};
      for (const row of result.rows) settings[row.key] = row.value;
      res.json({ settings });
    } catch (e) { res.status(500).json({ error: e.message }); }
  });

  app.put('/api/admin/settings', auth, adminAuth, async (req, res) => {
    try {
      const { settings } = req.body;
      if (!settings || typeof settings !== 'object') return res.status(400).json({ error: '参数格式错误' });
      for (const [key, value] of Object.entries(settings)) {
        await pool.query(
          `INSERT INTO settings (key, value, updated_at) VALUES ($1, $2, NOW())
           ON CONFLICT (key) DO UPDATE SET value = $2, updated_at = NOW()`,
          [key, JSON.stringify(value)]
        );
      }
      await logAction(pool, req.user.wallet, 'update_settings', null, { keys: Object.keys(settings) });
      res.json({ ok: true });
    } catch (e) { res.status(500).json({ error: e.message }); }
  });

  // ========== 7. 操作日志 ==========
  app.get('/api/admin/logs', auth, adminAuth, async (req, res) => {
    try {
      const { page = 1, limit = 30, action, admin_wallet } = req.query;
      const offset = (Math.max(1, parseInt(page)) - 1) * parseInt(limit);
      const conditions = [];
      const params = [];
      let idx = 1;
      if (action) { conditions.push(`action = $${idx++}`); params.push(action); }
      if (admin_wallet) { conditions.push(`admin_wallet = $${idx++}`); params.push(admin_wallet.toLowerCase()); }
      const where = conditions.length ? 'WHERE ' + conditions.join(' AND ') : '';
      const countQ = await pool.query(`SELECT COUNT(*) FROM admin_logs ${where}`, params);
      const dataQ = await pool.query(
        `SELECT * FROM admin_logs ${where} ORDER BY created_at DESC LIMIT $${idx++} OFFSET $${idx++}`,
        [...params, parseInt(limit), offset]
      );
      res.json({
        total: parseInt(countQ.rows[0].count),
        page: parseInt(page),
        limit: parseInt(limit),
        logs: dataQ.rows,
      });
    } catch (e) { res.status(500).json({ error: e.message }); }
  });

} // end registerAdminRoutes
