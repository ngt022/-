// inventory-gd.js — 基于 game_data JSONB 的 inventory 路由
// 替代旧的 inventory.js（那个用的是独立的 herbs/pills 表，和主系统不通）
import express from 'express';

const router = express.Router();

// 丹方配置（和前端 pills.js 保持一致）
const PILL_RECIPES = {
  spirit_gathering:      { name:'聚灵丹', grade:1, materials:[{herb:'spirit_grass',count:2},{herb:'cloud_flower',count:1}], successRate:0.9 },
  cultivation_boost:     { name:'聚气丹', grade:2, materials:[{herb:'cloud_flower',count:2},{herb:'thunder_root',count:1}], successRate:0.8 },
  spirit_recovery:       { name:'回灵丹', grade:2, materials:[{herb:'dark_yin_grass',count:2},{herb:'frost_lotus',count:1}], successRate:0.8 },
  thunder_power:         { name:'雷灵丹', grade:3, materials:[{herb:'thunder_root',count:2},{herb:'dragon_breath_herb',count:1}], successRate:0.7 },
  essence_condensation:  { name:'凝元丹', grade:3, materials:[{herb:'nine_leaf_lingzhi',count:2},{herb:'purple_ginseng',count:1}], successRate:0.7 },
  mind_clarity:          { name:'清心丹', grade:3, materials:[{herb:'frost_lotus',count:2},{herb:'fire_heart_flower',count:1}], successRate:0.7 },
  immortal_essence:      { name:'仙灵丹', grade:4, materials:[{herb:'dragon_breath_herb',count:2},{herb:'immortal_jade_grass',count:1}], successRate:0.6 },
  fire_essence:          { name:'火元丹', grade:4, materials:[{herb:'fire_heart_flower',count:2},{herb:'dragon_breath_herb',count:1}], successRate:0.6 },
  five_elements_pill:    { name:'五行丹', grade:5, materials:[{herb:'five_elements_grass',count:2},{herb:'phoenix_feather_herb',count:1}], successRate:0.5 },
  celestial_essence_pill:{ name:'天元丹', grade:6, materials:[{herb:'celestial_dew_grass',count:2},{herb:'moonlight_orchid',count:1}], successRate:0.4 },
  sun_moon_pill:         { name:'日月丹', grade:7, materials:[{herb:'sun_essence_flower',count:2},{herb:'moonlight_orchid',count:2}], successRate:0.3 },
  phoenix_rebirth_pill:  { name:'涅槃丹', grade:8, materials:[{herb:'phoenix_feather_herb',count:3},{herb:'celestial_dew_grass',count:1}], successRate:0.2 },
};

// 丹药效果映射
const EFFECT_MAP = {
  1: { type:'spiritRate', value:0.2, duration:3600000 },
  2: { type:'cultivationRate', value:0.3, duration:1800000 },
  3: { type:'combatBoost', value:0.4, duration:900000 },
  4: { type:'allAttributes', value:0.5, duration:600000 },
  5: { type:'allAttributes', value:0.8, duration:1200000 },
  6: { type:'cultivationRate', value:1.0, duration:1800000 },
  7: { type:'spiritCap', value:1.5, duration:2400000 },
  8: { type:'autoHeal', value:0.1, duration:3600000 },
};

export default function(pool, auth) {

  // GET /herbs — 从 game_data.herbs 读取
  router.get('/herbs', auth, async (req, res) => {
    try {
      const wallet = req.user.wallet;
      const r = await pool.query('SELECT game_data FROM players WHERE wallet=$1', [wallet]);
      if (!r.rows.length) return res.status(404).json({ success:false, message:'玩家不存在' });
      const gd = typeof r.rows[0].game_data === 'string' ? JSON.parse(r.rows[0].game_data) : (r.rows[0].game_data || {});
      // 返回格式兼容旧 inventory.js
      const herbs = (gd.herbs || []).map((h, i) => ({
        id: h.id || h.herbId || h.herb_id,
        herb_id: h.id || h.herbId || h.herb_id,
        name: h.name,
        quality: h.quality,
        value: h.value || 0,
        created_at: h.obtainedAt || Date.now(),
        _index: i
      }));
      res.json({ success:true, data:herbs });
    } catch(e) { res.status(500).json({ success:false, message:e.message }); }
  });

  // POST /herbs — 添加焰草到 game_data.herbs
  router.post('/herbs', auth, async (req, res) => {
    try {
      const { herbId, name, quality, value } = req.body;
      const wallet = req.user.wallet;
      if (!herbId || !name) return res.status(400).json({ success:false, message:'参数不完整' });
      const r = await pool.query('SELECT game_data FROM players WHERE wallet=$1', [wallet]);
      if (!r.rows.length) return res.status(404).json({ success:false, message:'玩家不存在' });
      const gd = typeof r.rows[0].game_data === 'string' ? JSON.parse(r.rows[0].game_data) : (r.rows[0].game_data || {});
      if (!gd.herbs) gd.herbs = [];
      const herb = { id:herbId, herbId, herb_id:herbId, name, quality:quality||'common', value:value||0, obtainedAt:Date.now() };
      gd.herbs.push(herb);
      await pool.query('UPDATE players SET game_data=$1 WHERE wallet=$2', [JSON.stringify(gd), wallet]);
      res.json({ success:true, data:herb });
    } catch(e) { res.status(500).json({ success:false, message:e.message }); }
  });

  // GET /pills — 从 game_data 读取炼制的丹药
  router.get('/pills', auth, async (req, res) => {
    try {
      const wallet = req.user.wallet;
      const r = await pool.query('SELECT game_data FROM players WHERE wallet=$1', [wallet]);
      if (!r.rows.length) return res.status(404).json({ success:false, message:'玩家不存在' });
      const gd = typeof r.rows[0].game_data === 'string' ? JSON.parse(r.rows[0].game_data) : (r.rows[0].game_data || {});
      res.json({ success:true, data: gd.craftedPills || [] });
    } catch(e) { res.status(500).json({ success:false, message:e.message }); }
  });

  // GET /recipes — 从 game_data.pillRecipes 读取
  router.get('/recipes', auth, async (req, res) => {
    try {
      const wallet = req.user.wallet;
      const r = await pool.query('SELECT game_data FROM players WHERE wallet=$1', [wallet]);
      if (!r.rows.length) return res.status(404).json({ success:false, message:'玩家不存在' });
      const gd = typeof r.rows[0].game_data === 'string' ? JSON.parse(r.rows[0].game_data) : (r.rows[0].game_data || {});
      // 返回格式兼容
      const recipes = (gd.pillRecipes || []).map(id => ({ recipe_id: id }));
      res.json({ success:true, data:recipes });
    } catch(e) { res.status(500).json({ success:false, message:e.message }); }
  });

  // POST /craft — 炼丹（基于 game_data）
  router.post('/craft', auth, async (req, res) => {
    try {
      const { recipeId } = req.body;
      const wallet = req.user.wallet;
      if (!recipeId) return res.status(400).json({ success:false, message:'缺少配方ID' });
      const recipe = PILL_RECIPES[recipeId];
      if (!recipe) return res.status(400).json({ success:false, message:'未知配方' });

      const r = await pool.query('SELECT game_data, level FROM players WHERE wallet=$1', [wallet]);
      if (!r.rows.length) return res.status(404).json({ success:false, message:'玩家不存在' });
      const gd = typeof r.rows[0].game_data === 'string' ? JSON.parse(r.rows[0].game_data) : (r.rows[0].game_data || {});
      const level = r.rows[0].level || gd.level || 1;

      // 检查是否学会配方
      if (!gd.pillRecipes || !gd.pillRecipes.includes(recipeId)) {
        return res.status(400).json({ success:false, message:'未学会该配方' });
      }

      // 检查材料
      const herbs = gd.herbs || [];
      const herbCount = {};
      herbs.forEach(h => {
        const hid = h.id || h.herbId || h.herb_id;
        herbCount[hid] = (herbCount[hid] || 0) + 1;
      });
      for (const mat of recipe.materials) {
        if ((herbCount[mat.herb] || 0) < mat.count) {
          return res.status(400).json({ success:false, message:`材料不足: ${mat.herb} (${herbCount[mat.herb]||0}/${mat.count})` });
        }
      }

      // 扣除材料
      for (const mat of recipe.materials) {
        let remaining = mat.count;
        for (let i = herbs.length - 1; i >= 0 && remaining > 0; i--) {
          const hid = herbs[i].id || herbs[i].herbId || herbs[i].herb_id;
          if (hid === mat.herb) {
            herbs.splice(i, 1);
            remaining--;
          }
        }
      }
      gd.herbs = herbs;

      // 计算成功率
      const luck = gd.luck || 1;
      const alchemyRate = gd.alchemyRate || 1;
      const baseRate = recipe.successRate;
      const luckBonus = (luck - 1) * 0.05;
      const alchemyBonus = (alchemyRate - 1) * 0.1;
      const finalRate = Math.min(0.95, baseRate + luckBonus + alchemyBonus);

      const isSuccess = Math.random() < finalRate;

      if (!isSuccess) {
        // 失败也要保存扣除的材料
        await pool.query('UPDATE players SET game_data=$1 WHERE wallet=$2', [JSON.stringify(gd), wallet]);
        return res.json({ success:false, message:'炼丹失败，材料已消耗', rate:finalRate });
      }

      // 成功 — 生成丹药效果
      const levelMult = 1 + (level - 1) * 0.1;
      const baseEffect = EFFECT_MAP[recipe.grade] || EFFECT_MAP[1];
      const effect = {
        type: baseEffect.type,
        value: baseEffect.value * levelMult,
        duration: baseEffect.duration
      };

      // 丹药存入 game_data.craftedPills
      if (!gd.craftedPills) gd.craftedPills = [];
      const pill = {
        id: Date.now() + Math.random(),
        recipeId,
        name: recipe.name,
        grade: recipe.grade,
        effect,
        craftedAt: Date.now()
      };
      gd.craftedPills.push(pill);

      // 统计
      gd.pillsCrafted = (gd.pillsCrafted || 0) + 1;

      await pool.query('UPDATE players SET game_data=$1 WHERE wallet=$2', [JSON.stringify(gd), wallet]);
      res.json({ success:true, data:pill, message:`炼制${recipe.name}成功！`, rate:finalRate, effect });
    } catch(e) { res.status(500).json({ success:false, message:e.message }); }
  });

  // POST /pills/use — 使用焰丹
  router.post('/pills/use', auth, async (req, res) => {
    try {
      const { pillId } = req.body;
      const wallet = req.user.wallet;
      if (!pillId) return res.status(400).json({ success:false, message:'缺少焰丹ID' });

      const r = await pool.query('SELECT game_data FROM players WHERE wallet=$1', [wallet]);
      if (!r.rows.length) return res.status(404).json({ success:false, message:'玩家不存在' });
      const gd = typeof r.rows[0].game_data === 'string' ? JSON.parse(r.rows[0].game_data) : (r.rows[0].game_data || {});

      const pills = gd.craftedPills || [];
      const idx = pills.findIndex(p => p.id == pillId);
      if (idx === -1) return res.status(404).json({ success:false, message:'焰丹不存在' });

      const pill = pills[idx];
      const effect = pill.effect || {};

      // 应用效果到 buffs
      if (effect.duration) {
        if (!gd.buffs) gd.buffs = {};
        gd.buffs[effect.type] = Date.now() + effect.duration;
        // 存丹药buff数值，供后端读取
        if (!gd.pillBuffValues) gd.pillBuffValues = {};
        gd.pillBuffValues[effect.type] = effect.value || 0;
      }

      // 移除已使用的丹药
      pills.splice(idx, 1);
      gd.craftedPills = pills;
      gd.pillsConsumed = (gd.pillsConsumed || 0) + 1;

      await pool.query('UPDATE players SET game_data=$1 WHERE wallet=$2', [JSON.stringify(gd), wallet]);
      res.json({ success:true, data:{ effect, message:'使用成功' } });
    } catch(e) { res.status(500).json({ success:false, message:e.message }); }
  });

  // POST /pills/add — GM空投焰丹
  router.post('/pills/add', auth, async (req, res) => {
    try {
      const { recipeId, name, description, effect } = req.body;
      const wallet = req.user.wallet;
      if (!name) return res.status(400).json({ success:false, message:'缺少焰丹名称' });

      const r = await pool.query('SELECT game_data FROM players WHERE wallet=$1', [wallet]);
      if (!r.rows.length) return res.status(404).json({ success:false, message:'玩家不存在' });
      const gd = typeof r.rows[0].game_data === 'string' ? JSON.parse(r.rows[0].game_data) : (r.rows[0].game_data || {});

      if (!gd.craftedPills) gd.craftedPills = [];
      const pill = {
        id: Date.now() + Math.random(),
        recipeId: recipeId || null,
        name,
        description: description || '',
        effect: typeof effect === 'string' ? JSON.parse(effect) : (effect || {}),
        craftedAt: Date.now()
      };
      gd.craftedPills.push(pill);

      await pool.query('UPDATE players SET game_data=$1 WHERE wallet=$2', [JSON.stringify(gd), wallet]);
      res.json({ success:true, data:pill });
    } catch(e) { res.status(500).json({ success:false, message:e.message }); }
  });

  return router;
}
