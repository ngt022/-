import { Router } from 'express'
import pool from '../db.js'
import { auth } from '../middleware/auth.js'
import { generateEquipment, enhanceEquipment, reforgeEquipment, sellPrices } from '../utils/equipment-gen.js'

const router = Router()

// 属性字段映射：装备stat key → 数据库字段
const statFieldMap = {
  attack: 'base_attack', health: 'base_health', defense: 'base_defense', speed: 'base_speed',
  critRate: 'crit_rate', comboRate: 'combo_rate', counterRate: 'counter_rate',
  stunRate: 'stun_rate', dodgeRate: 'dodge_rate', vampireRate: 'vampire_rate',
  critResist: 'crit_resist', comboResist: 'combo_resist', counterResist: 'counter_resist',
  stunResist: 'stun_resist', dodgeResist: 'dodge_resist', vampireResist: 'vampire_resist',
  healBoost: 'heal_boost', critDamageBoost: 'crit_damage_boost', critDamageReduce: 'crit_damage_reduce',
  finalDamageBoost: 'final_damage_boost', finalDamageReduce: 'final_damage_reduce',
  combatBoost: 'combat_boost', resistanceBoost: 'resistance_boost',
  spiritRate: 'spirit_rate', cultivationRate: 'cultivation_rate'
}

// 装备/卸下时更新玩家属性
async function applyEquipStats(userId, stats, add = true) {
  const s = typeof stats === 'string' ? JSON.parse(stats) : stats
  const updates = []
  const values = []
  let idx = 1
  for (const [statKey, val] of Object.entries(s)) {
    const dbField = statFieldMap[statKey]
    if (dbField && typeof val === 'number') {
      const op = add ? '+' : '-'
      updates.push(`${dbField} = ${dbField} ${op} $${idx}`)
      values.push(val)
      idx++
    }
  }
  if (updates.length > 0) {
    values.push(userId)
    await pool.query(`UPDATE player_data SET ${updates.join(', ')}, updated_at = NOW() WHERE user_id = $${idx}`, values)
  }
}

// GET /api/equipment
router.get('/', auth, async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM equipment WHERE owner_id = $1 ORDER BY created_at DESC', [req.user.userId])
    res.json({ success: true, data: result.rows })
  } catch (err) {
    console.error('Get equipment error:', err)
    res.status(500).json({ success: false, message: '服务器错误' })
  }
})

// POST /api/equipment/generate
router.post('/generate', auth, async (req, res) => {
  try {
    const { level, type, quality } = req.body
    const equip = generateEquipment(level || 1, type || null, quality || null)
    const result = await pool.query(
      `INSERT INTO equipment (owner_id, name, type, slot, quality, level, required_realm, stats) VALUES ($1,$2,$3,$4,$5,$6,$7,$8) RETURNING *`,
      [req.user.userId, equip.name, equip.type, equip.slot, equip.quality, equip.level, equip.requiredRealm, JSON.stringify(equip.stats)]
    )
    res.json({ success: true, data: result.rows[0] })
  } catch (err) {
    console.error('Generate equipment error:', err)
    res.status(500).json({ success: false, message: '服务器错误' })
  }
})

// PUT /api/equipment/:id/equip
router.put('/:id/equip', auth, async (req, res) => {
  try {
    const { id } = req.params
    const equip = await pool.query('SELECT * FROM equipment WHERE id = $1 AND owner_id = $2', [id, req.user.userId])
    if (equip.rows.length === 0) return res.status(404).json({ success: false, message: '装备不存在' })

    const item = equip.rows[0]
    // 先卸下同栏位已装备的，并移除其属性加成
    const oldEquip = await pool.query(
      'SELECT * FROM equipment WHERE owner_id = $1 AND equipped_slot = $2 AND is_equipped = true',
      [req.user.userId, item.slot]
    )
    if (oldEquip.rows.length > 0) {
      await applyEquipStats(req.user.userId, oldEquip.rows[0].stats, false)
      await pool.query(
        'UPDATE equipment SET is_equipped = false, equipped_slot = null WHERE id = $1',
        [oldEquip.rows[0].id]
      )
    }
    // 装备新的
    const result = await pool.query(
      'UPDATE equipment SET is_equipped = true, equipped_slot = $1 WHERE id = $2 RETURNING *',
      [item.slot, id]
    )
    // 应用新装备属性加成
    await applyEquipStats(req.user.userId, item.stats, true)
    res.json({ success: true, data: result.rows[0] })
  } catch (err) {
    console.error('Equip error:', err)
    res.status(500).json({ success: false, message: '服务器错误' })
  }
})

// PUT /api/equipment/:id/unequip
router.put('/:id/unequip', auth, async (req, res) => {
  try {
    const { id } = req.params
    const equip = await pool.query('SELECT * FROM equipment WHERE id = $1 AND owner_id = $2', [id, req.user.userId])
    if (equip.rows.length === 0) return res.status(404).json({ success: false, message: '装备不存在' })

    // 移除属性加成
    await applyEquipStats(req.user.userId, equip.rows[0].stats, false)
    const result = await pool.query(
      'UPDATE equipment SET is_equipped = false, equipped_slot = null WHERE id = $1 AND owner_id = $2 RETURNING *',
      [id, req.user.userId]
    )
    res.json({ success: true, data: result.rows[0] })
  } catch (err) {
    console.error('Unequip error:', err)
    res.status(500).json({ success: false, message: '服务器错误' })
  }
})

// PUT /api/equipment/:id/enhance
router.put('/:id/enhance', auth, async (req, res) => {
  try {
    const { id } = req.params
    const equip = await pool.query('SELECT * FROM equipment WHERE id = $1 AND owner_id = $2', [id, req.user.userId])
    if (equip.rows.length === 0) return res.status(404).json({ success: false, message: '装备不存在' })

    const item = equip.rows[0]
    const wasEquipped = item.is_equipped
    // 如果已装备，先移除旧属性
    if (wasEquipped) await applyEquipStats(req.user.userId, item.stats, false)

    const enhanced = enhanceEquipment(item)
    const result = await pool.query(
      'UPDATE equipment SET enhance_level = $1, stats = $2 WHERE id = $3 RETURNING *',
      [enhanced.enhance_level, JSON.stringify(enhanced.stats), id]
    )
    // 如果已装备，应用新属性
    if (wasEquipped) await applyEquipStats(req.user.userId, enhanced.stats, true)
    res.json({ success: true, data: result.rows[0] })
  } catch (err) {
    console.error('Enhance error:', err)
    res.status(500).json({ success: false, message: '服务器错误' })
  }
})

// PUT /api/equipment/:id/reforge
router.put('/:id/reforge', auth, async (req, res) => {
  try {
    const { id } = req.params
    const equip = await pool.query('SELECT * FROM equipment WHERE id = $1 AND owner_id = $2', [id, req.user.userId])
    if (equip.rows.length === 0) return res.status(404).json({ success: false, message: '装备不存在' })

    const item = equip.rows[0]
    const wasEquipped = item.is_equipped
    if (wasEquipped) await applyEquipStats(req.user.userId, item.stats, false)

    const reforged = reforgeEquipment(item)
    const result = await pool.query(
      'UPDATE equipment SET stats = $1 WHERE id = $2 RETURNING *',
      [JSON.stringify(reforged.stats), id]
    )
    if (wasEquipped) await applyEquipStats(req.user.userId, reforged.stats, true)
    res.json({ success: true, data: result.rows[0] })
  } catch (err) {
    console.error('Reforge error:', err)
    res.status(500).json({ success: false, message: '服务器错误' })
  }
})

// DELETE /api/equipment/:id/sell
router.delete('/:id/sell', auth, async (req, res) => {
  try {
    const { id } = req.params
    const equip = await pool.query('SELECT * FROM equipment WHERE id = $1 AND owner_id = $2', [id, req.user.userId])
    if (equip.rows.length === 0) return res.status(404).json({ success: false, message: '装备不存在' })
    if (equip.rows[0].is_equipped) return res.status(400).json({ success: false, message: '请先卸下装备' })

    const price = sellPrices[equip.rows[0].quality] || 10
    await pool.query('DELETE FROM equipment WHERE id = $1', [id])
    await pool.query('UPDATE player_data SET spirit_stones = spirit_stones + $1 WHERE user_id = $2', [price, req.user.userId])
    res.json({ success: true, data: { soldPrice: price } })
  } catch (err) {
    console.error('Sell error:', err)
    res.status(500).json({ success: false, message: '服务器错误' })
  }
})

export default router
