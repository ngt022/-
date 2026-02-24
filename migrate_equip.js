// Migrate existing equipment: recalc percentage stats
// Run inside docker: node /tmp/migrate_equip.js
const pg = require('pg');
const pool = new pg.Pool({connectionString:'postgresql://roon_user:RoonG%40ming2026!@127.0.0.1:5432/xiuxian_test'});

const PERCENT_CAPS = {
  critRate: 0.15, critDamageBoost: 0.20, dodgeRate: 0.10,
  vampireRate: 0.08, comboRate: 0.10, counterRate: 0.08,
  stunRate: 0.08, healBoost: 0.10, spiritRate: 0.10,
  combatBoost: 0.08, resistanceBoost: 0.08,
  finalDamageBoost: 0.08, finalDamageReduce: 0.12,
  critDamageReduce: 0.10, stunResist: 0.12,
  vampireResist: 0.10, dodgeResist: 0.10,
  comboResist: 0.10, counterResist: 0.10, critResist: 0.10,
  cultivationRate: 0.15
};

const equipmentQualities = {
  common: 1.0, uncommon: 1.5, rare: 2.5, epic: 4.0, legendary: 6.0, mythic: 10.0
};

const equipmentBaseStats = {
  weapon: { critRate: {min:0.01,max:0.03}, critDamageBoost: {min:0.02,max:0.06} },
  head: { stunResist: {min:0.05,max:0.1} },
  body: { finalDamageReduce: {min:0.05,max:0.1} },
  legs: { dodgeRate: {min:0.01,max:0.03} },
  feet: { dodgeRate: {min:0.01,max:0.03} },
  shoulder: { counterRate: {min:0.01,max:0.03} },
  hands: { critRate: {min:0.005,max:0.02}, comboRate: {min:0.01,max:0.03} },
  wrist: { counterRate: {min:0.01,max:0.03}, vampireRate: {min:0.01,max:0.03} },
  necklace: { healBoost: {min:0.02,max:0.05}, spiritRate: {min:0.02,max:0.05} },
  ring1: { critDamageBoost: {min:0.02,max:0.05}, finalDamageBoost: {min:0.01,max:0.03} },
  ring2: { critDamageReduce: {min:0.02,max:0.05}, resistanceBoost: {min:0.01,max:0.03} },
  belt: { combatBoost: {min:0.01,max:0.03} },
  artifact: { critRate: {min:0.02,max:0.05}, comboRate: {min:0.01,max:0.03} }
};

function fixItem(item) {
  if (!item || !item.stats || !item.type) return false;
  const qualityMod = equipmentQualities[item.quality] || 1;
  const sqrtMod = Math.sqrt(qualityMod);
  const baseRange = equipmentBaseStats[item.type] || {};
  let changed = false;
  
  for (const stat of Object.keys(item.stats)) {
    if (!(stat in PERCENT_CAPS)) continue;
    const cap = PERCENT_CAPS[stat];
    const range = baseRange[stat];
    if (range) {
      // Regenerate: random value in range * sqrt(qualityMod), capped
      const mid = (range.min + range.max) / 2;
      const newVal = Math.min(cap, Math.round(mid * sqrtMod * 100) / 100);
      if (item.stats[stat] !== newVal) {
        item.stats[stat] = newVal;
        changed = true;
      }
    } else if (item.stats[stat] > cap) {
      item.stats[stat] = cap;
      changed = true;
    }
  }
  return changed;
}

(async () => {
  const players = (await pool.query('SELECT wallet, game_data FROM players')).rows;
  let totalFixed = 0, playersFixed = 0;
  
  for (const p of players) {
    const gd = p.game_data;
    if (!gd) continue;
    let playerChanged = false;
    
    // Fix equipped artifacts
    if (gd.equippedArtifacts) {
      for (const slot of Object.keys(gd.equippedArtifacts)) {
        if (fixItem(gd.equippedArtifacts[slot])) {
          playerChanged = true;
          totalFixed++;
        }
      }
    }
    
    // Fix inventory items
    if (gd.items && Array.isArray(gd.items)) {
      for (const item of gd.items) {
        if (item.stats && fixItem(item)) {
          totalFixed++;
          playerChanged = true;
        }
      }
    }
    
    if (playerChanged) {
      await pool.query('UPDATE players SET game_data=$1 WHERE wallet=$2', [JSON.stringify(gd), p.wallet]);
      playersFixed++;
    }
  }
  
  console.log('Fixed', totalFixed, 'items across', playersFixed, 'players');
  pool.end();
})();
