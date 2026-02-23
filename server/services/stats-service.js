import logger from "./logger.js";
/**
 * stats-service.js — Single Source of Truth for player final stats.
 * 
 * ALL combat/attribute reads MUST go through this module.
 * Replaces: recalcDerivedStats, buildPlayerCombatStats, boss inline calc, PK frontend stats.
 *
 * Design decisions:
 * - _nakedBase is DERIVED from level/realm every time, never cached permanently
 * - Equipment bonuses computed from equippedArtifacts
 * - Pet bonuses computed from activePet
 * - Mount/Title bonuses computed from DB tables
 * - Result cached in player_stats_snapshot (M2), but always recomputable
 */

const DEBUG = process.env.DEBUG_BATTLE_TRACE === 'true';

// ============================================================
// Realm -> naked base attributes mapping
// Each realm tier has 9 sub-levels (一层 to 九层)
// ============================================================
const REALM_BASE_STATS = [
  // 燃火期 (0-8)
  ...Array.from({length: 9}, (_, i) => ({ attack: 10 + i*5, health: 100 + i*50, defense: 5 + i*3, speed: 10 + i*2 })),
  // 灵火期 (9-17)
  ...Array.from({length: 9}, (_, i) => ({ attack: 55 + i*8, health: 550 + i*80, defense: 32 + i*5, speed: 28 + i*3 })),
  // 地火期 (18-26)
  ...Array.from({length: 9}, (_, i) => ({ attack: 127 + i*12, health: 1270 + i*120, defense: 77 + i*8, speed: 55 + i*4 })),
  // 天火期 (27-35)
  ...Array.from({length: 9}, (_, i) => ({ attack: 235 + i*18, health: 2350 + i*180, defense: 149 + i*12, speed: 91 + i*5 })),
  // 焰皇期 (36-44)
  ...Array.from({length: 9}, (_, i) => ({ attack: 397 + i*25, health: 3970 + i*250, defense: 257 + i*16, speed: 136 + i*6 })),
  // 焰帝期 (45-53)
  ...Array.from({length: 9}, (_, i) => ({ attack: 622 + i*35, health: 6220 + i*350, defense: 401 + i*22, speed: 190 + i*8 })),
  // 焰神期 (54-62)
  ...Array.from({length: 9}, (_, i) => ({ attack: 937 + i*50, health: 9370 + i*500, defense: 599 + i*30, speed: 262 + i*10 })),
];

/**
 * Derive naked base attributes from level + realmIndex.
 * This replaces the old _nakedBase snapshot approach.
 */
function deriveNakedBase(gameData) {
  const realmIndex = gameData.realmIndex || 0;
  const level = gameData.level || 1;
  
  // Use realm table if available
  if (realmIndex < REALM_BASE_STATS.length) {
    const base = REALM_BASE_STATS[realmIndex];
    // Level within realm adds small incremental bonus
    const levelBonus = Math.floor(level * 0.5);
    return {
      attack: base.attack + levelBonus,
      health: base.health + levelBonus * 5,
      defense: base.defense + levelBonus,
      speed: base.speed + Math.floor(levelBonus * 0.3)
    };
  }
  
  // Fallback for very high realms: use existing _nakedBase or defaults
  if (gameData._nakedBase) {
    return { ...gameData._nakedBase };
  }
  return { attack: 10, health: 100, defense: 5, speed: 10 };
}

/**
 * Compute equipment bonuses from equippedArtifacts.
 */
function computeEquipmentBonuses(equippedArtifacts) {
  const ab = {
    attack:0, health:0, defense:0, speed:0,
    critRate:0, comboRate:0, counterRate:0, stunRate:0, dodgeRate:0, vampireRate:0,
    critResist:0, comboResist:0, counterResist:0, stunResist:0, dodgeResist:0, vampireResist:0,
    healBoost:0, critDamageBoost:0, critDamageReduce:0, finalDamageBoost:0, finalDamageReduce:0,
    combatBoost:0, resistanceBoost:0, cultivationRate:0, spiritRate:0
  };
  if (!equippedArtifacts) return ab;
  for (const slot of Object.keys(equippedArtifacts)) {
    const item = equippedArtifacts[slot];
    if (!item || !item.stats) continue;
    for (const [k, v] of Object.entries(item.stats)) {
      if (k in ab) ab[k] += v;
    }
  }
  return ab;
}

/**
 * Compute pet bonuses (percentage-based, matches dungeon.js buildPlayerCombatStats).
 */
function computePetBonuses(activePet) {
  const bonus = {
    attack:0, health:0, defense:0, speed:0,
    critRate:0, comboRate:0, counterRate:0, stunRate:0, dodgeRate:0, vampireRate:0,
    critResist:0, comboResist:0, counterResist:0, stunResist:0, dodgeResist:0, vampireResist:0,
    healBoost:0, critDamageBoost:0, critDamageReduce:0, finalDamageBoost:0, finalDamageReduce:0,
    combatBoost:0, resistanceBoost:0
  };
  if (!activePet || activePet.deployed === false) return bonus;
  
  const qualityBonusMap = { divine: 0.15, celestial: 0.12, mystic: 0.09, spiritual: 0.06, mortal: 0.03 };
  const baseBonus = qualityBonusMap[activePet.rarity] || 0;
  const starBonus = (activePet.star || 0) * 0.01;
  const levelBonus = ((activePet.level || 1) - 1) * (baseBonus * 0.1);
  const phase = Math.floor((activePet.star || 0) / 5);
  const phaseBonus = phase * (baseBonus * 0.5);
  const finalBonus = baseBonus + starBonus + levelBonus + phaseBonus;
  const combatBonus = finalBonus * 0.5;
  
  bonus.attack = finalBonus;
  bonus.health = finalBonus;
  bonus.defense = finalBonus;
  bonus.critRate = combatBonus;
  bonus.comboRate = combatBonus;
  bonus.counterRate = combatBonus;
  bonus.stunRate = combatBonus;
  bonus.dodgeRate = combatBonus;
  bonus.vampireRate = combatBonus;
  bonus.critResist = combatBonus;
  bonus.comboResist = combatBonus;
  bonus.counterResist = combatBonus;
  bonus.stunResist = combatBonus;
  bonus.dodgeResist = combatBonus;
  bonus.vampireResist = combatBonus;
  bonus.healBoost = combatBonus;
  bonus.critDamageBoost = combatBonus;
  bonus.critDamageReduce = combatBonus;
  bonus.finalDamageBoost = combatBonus;
  bonus.finalDamageReduce = combatBonus;
  bonus.combatBoost = combatBonus;
  bonus.resistanceBoost = combatBonus;
  
  return bonus;
}

/**
 * Old-style pet bonus (absolute values, for backward compat with game_data fields).
 */
function computePetBonusAbsolute(activePet) {
  if (!activePet || activePet.deployed === false) return { attack:0, health:0, defense:0, speed:0 };
  const q = activePet.quality || {};
  return {
    attack: (q.strength || 0) * (activePet.level || 1),
    health: (q.constitution || 0) * (activePet.level || 1) * 5,
    defense: (q.constitution || 0) * (activePet.level || 1) * 0.5,
    speed: (q.agility || 0) * (activePet.level || 1) * 0.3
  };
}

const clamp01 = v => Math.min(1, Math.max(0, v));

/**
 * computeFinalStats — THE single source of truth.
 * 
 * @param {object} gameData - player's game_data JSONB
 * @param {object} opts - { mountAtkPct, titleAtkPct } from DB queries (optional)
 * @returns {object} finalStats for combat use
 */
export function computeFinalStats(gameData, opts = {}) {
  const naked = deriveNakedBase(gameData);
  const equip = computeEquipmentBonuses(gameData.equippedArtifacts);
  const pet = computePetBonusAbsolute(gameData.activePet);
  const petPct = computePetBonuses(gameData.activePet);
  
  const mountAtkPct = opts.mountAtkPct || 0;
  const titleAtkPct = opts.titleAtkPct || 0;
  
  // Base attributes = naked + equipment flat + pet flat
  const baseAttack = naked.attack + equip.attack + pet.attack;
  const baseHealth = naked.health + equip.health + pet.health;
  const baseDefense = naked.defense + equip.defense + pet.defense;
  const baseSpeed = naked.speed + equip.speed + pet.speed;
  
  // Apply mount/title percentage bonuses to attack
  const pctMult = 1 + mountAtkPct + titleAtkPct;
  
  const finalStats = {
    // Base (for display + combat)
    health: Math.floor(baseHealth),
    attack: Math.floor(baseAttack * pctMult),
    defense: Math.floor(baseDefense),
    speed: Math.floor(baseSpeed),
    
    // For CombatManager compatibility (uses 'damage' not 'attack')
    damage: Math.floor(baseAttack * pctMult),
    maxHealth: Math.floor(baseHealth),
    
    // Combat rates
    critRate: clamp01(equip.critRate + petPct.critRate),
    comboRate: clamp01(equip.comboRate + petPct.comboRate),
    counterRate: clamp01(equip.counterRate + petPct.counterRate),
    stunRate: clamp01(equip.stunRate + petPct.stunRate),
    dodgeRate: clamp01(equip.dodgeRate + petPct.dodgeRate),
    vampireRate: clamp01(equip.vampireRate + petPct.vampireRate),
    
    // Resistances
    critResist: clamp01(equip.critResist + petPct.critResist),
    comboResist: clamp01(equip.comboResist + petPct.comboResist),
    counterResist: clamp01(equip.counterResist + petPct.counterResist),
    stunResist: clamp01(equip.stunResist + petPct.stunResist),
    dodgeResist: clamp01(equip.dodgeResist + petPct.dodgeResist),
    vampireResist: clamp01(equip.vampireResist + petPct.vampireResist),
    
    // Special
    healBoost: equip.healBoost + petPct.healBoost,
    critDamageBoost: equip.critDamageBoost + petPct.critDamageBoost,
    critDamageReduce: equip.critDamageReduce + petPct.critDamageReduce,
    finalDamageBoost: equip.finalDamageBoost + petPct.finalDamageBoost,
    finalDamageReduce: equip.finalDamageReduce + petPct.finalDamageReduce,
    combatBoost: equip.combatBoost + petPct.combatBoost,
    resistanceBoost: equip.resistanceBoost + petPct.resistanceBoost,
    
    // Utility rates
    cultivationRate: 1 + equip.cultivationRate,
    spiritRate: 1 + equip.spiritRate,
  };
  
  // === 丹药 buff 加成 ===
  const buffs = gameData?.buffs || {};
  const pbv = gameData?.pillBuffValues || {};
  const now = Date.now();

  // combatBoost 丹药 (雷灵丹等): 全属性百分比加成
  if (buffs.combatBoost && buffs.combatBoost > now && pbv.combatBoost) {
    const boost = pbv.combatBoost;
    finalStats.attack = Math.floor(finalStats.attack * (1 + boost));
    finalStats.damage = Math.floor(finalStats.damage * (1 + boost));
    finalStats.defense = Math.floor(finalStats.defense * (1 + boost));
    finalStats.health = Math.floor(finalStats.health * (1 + boost));
    finalStats.maxHealth = Math.floor(finalStats.maxHealth * (1 + boost));
    finalStats.speed = Math.floor(finalStats.speed * (1 + boost));
  }

  // allAttributes 丹药 (仙灵丹/五行丹): 更强的全属性加成
  if (buffs.allAttributes && buffs.allAttributes > now && pbv.allAttributes) {
    const boost = pbv.allAttributes;
    finalStats.attack = Math.floor(finalStats.attack * (1 + boost));
    finalStats.damage = Math.floor(finalStats.damage * (1 + boost));
    finalStats.defense = Math.floor(finalStats.defense * (1 + boost));
    finalStats.health = Math.floor(finalStats.health * (1 + boost));
    finalStats.maxHealth = Math.floor(finalStats.maxHealth * (1 + boost));
    finalStats.speed = Math.floor(finalStats.speed * (1 + boost));
    finalStats.critRate = clamp01(finalStats.critRate + boost * 0.1);
    finalStats.comboRate = clamp01(finalStats.comboRate + boost * 0.05);
  }

  // spiritCap 丹药 (日月丹): 标记，供前端/焰灵系统读取
  if (buffs.spiritCap && buffs.spiritCap > now && pbv.spiritCap) {
    finalStats.spiritCapBoost = pbv.spiritCap;
  }

  return finalStats;
}

/**
 * Update game_data derived fields in-place (backward compat with old recalcDerivedStats).
 * Call this after any mutation to equippedArtifacts, level, realm, pet, etc.
 */
export function recalcAndPatch(gameData) {
  const naked = deriveNakedBase(gameData);
  const equip = computeEquipmentBonuses(gameData.equippedArtifacts);
  const pet = computePetBonusAbsolute(gameData.activePet);
  
  // Update _nakedBase to current derived value (fixes the stale snapshot bug)
  gameData._nakedBase = naked;
  
  // Update baseAttributes
  gameData.baseAttributes = {
    attack: naked.attack + equip.attack + pet.attack,
    health: naked.health + equip.health + pet.health,
    defense: naked.defense + equip.defense + pet.defense,
    speed: naked.speed + equip.speed + pet.speed
  };
  
  // Update artifactBonuses
  gameData.artifactBonuses = equip;
  
  // Ensure equippedArtifacts exists
  if (!gameData.equippedArtifacts) gameData.equippedArtifacts = {};
  
  // Update combat attributes
  gameData.combatAttributes = {
    critRate: equip.critRate,
    comboRate: equip.comboRate,
    counterRate: equip.counterRate,
    stunRate: equip.stunRate,
    dodgeRate: equip.dodgeRate,
    vampireRate: equip.vampireRate
  };
  
  gameData.combatResistance = {
    critResist: equip.critResist,
    comboResist: equip.comboResist,
    counterResist: equip.counterResist,
    stunResist: equip.stunResist,
    dodgeResist: equip.dodgeResist,
    vampireResist: equip.vampireResist
  };
  
  gameData.specialAttributes = {
    healBoost: equip.healBoost,
    critDamageBoost: equip.critDamageBoost,
    critDamageReduce: equip.critDamageReduce,
    finalDamageBoost: equip.finalDamageBoost,
    finalDamageReduce: equip.finalDamageReduce,
    combatBoost: equip.combatBoost,
    resistanceBoost: equip.resistanceBoost
  };
  
  return gameData;
}

/**
 * Get mount/title attack bonuses from DB.
 */
export async function getMountTitleBonuses(pool, wallet) {
  let mountAtkPct = 0, titleAtkPct = 0;
  try {
    const mRow = await pool.query(
      'SELECT m.attack_bonus FROM player_mounts pm JOIN mounts m ON pm.mount_id=m.id WHERE pm.wallet=$1 AND pm.is_active=true', [wallet]);
    if (mRow.rows[0]) mountAtkPct = mRow.rows[0].attack_bonus || 0;
    const tRow = await pool.query(
      'SELECT t.attack_bonus FROM player_titles pt JOIN titles t ON pt.title_id=t.id WHERE pt.wallet=$1 AND pt.is_active=true', [wallet]);
    if (tRow.rows[0]) titleAtkPct = tRow.rows[0].attack_bonus || 0;
  } catch(e) {}
  return { mountAtkPct, titleAtkPct };
}

/**
 * Full pipeline: load player from DB, compute final stats.
 * M2: Uses snapshot cache — if snapshot.state_version matches player.state_version, return cached.
 */
export async function getPlayerFinalStats(pool, wallet) {
  const r = await pool.query('SELECT id, game_data, state_version FROM players WHERE wallet=$1', [wallet]);
  if (!r.rows.length) return null;
  const player = r.rows[0];
  const playerId = player.id;
  const currentVersion = Number(player.state_version) || 0;

  // Check snapshot cache
  const snap = await pool.query(
    'SELECT state_version, final_stats, computed_at FROM player_stats_snapshot WHERE player_id=$1',
    [playerId]
  );
  if (snap.rows.length && Number(snap.rows[0].state_version) === currentVersion) {
    // Cache hit
    const cached = typeof snap.rows[0].final_stats === 'string'
      ? JSON.parse(snap.rows[0].final_stats)
      : snap.rows[0].final_stats;
    return {
      playerId,
      stateVersion: currentVersion,
      finalStats: cached,
      computedAt: snap.rows[0].computed_at,
      fromCache: true
    };
  }

  // Cache miss — recompute
  const gd = typeof player.game_data === 'string' ? JSON.parse(player.game_data) : (player.game_data || {});
  const bonuses = await getMountTitleBonuses(pool, wallet);
  const finalStats = computeFinalStats(gd, bonuses);
  const computedAt = new Date().toISOString();

  // Write snapshot (upsert)
  try {
    await pool.query(
      `INSERT INTO player_stats_snapshot (player_id, state_version, final_stats, computed_at)
       VALUES ($1, $2, $3, $4)
       ON CONFLICT (player_id) DO UPDATE SET
         state_version = $2, final_stats = $3, computed_at = $4`,
      [playerId, currentVersion, JSON.stringify(finalStats), computedAt]
    );
  } catch(e) {
    logger.error('[StatsSnapshot] write failed:', e.message);
  }

  return {
    playerId,
    stateVersion: currentVersion,
    finalStats,
    computedAt,
    fromCache: false
  };
}

/**
 * Invalidate snapshot (call after state_version changes).
 * Not strictly needed since getPlayerFinalStats checks version,
 * but useful for explicit invalidation.
 */
export async function invalidateSnapshot(pool, playerId) {
  try {
    await pool.query('DELETE FROM player_stats_snapshot WHERE player_id=$1', [playerId]);
  } catch(e) {}
}

/**
 * Get final stats by player ID (not wallet). Used internally.
 */
export async function getFinalStatsById(pool, playerId) {
  const r = await pool.query('SELECT wallet, game_data, state_version FROM players WHERE id=$1', [playerId]);
  if (!r.rows.length) return null;
  return getPlayerFinalStats(pool, r.rows[0].wallet);
}

/**
 * Log battle trace (if DEBUG_BATTLE_TRACE=true).
 */
export async function logBattleTrace(pool, opts) {
  if (!DEBUG) return;
  const { battleType, walletA, walletB, versionA, versionB, statsA, statsB, result } = opts;
  try {
    await pool.query(
      'INSERT INTO battle_trace_log (battle_type, player_a_wallet, player_b_wallet, player_a_version, player_b_version, stats_a, stats_b, result) VALUES ($1,$2,$3,$4,$5,$6,$7,$8)',
      [battleType, walletA, walletB || null, versionA, versionB || null,
       JSON.stringify(statsA), statsB ? JSON.stringify(statsB) : null, JSON.stringify(result)]
    );
  } catch(e) {
    logger.error('[BattleTrace] log failed:', e.message);
  }
}

export { deriveNakedBase, computeEquipmentBonuses, computePetBonuses, computePetBonusAbsolute, REALM_BASE_STATS };
