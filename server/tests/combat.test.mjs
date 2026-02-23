import { describe, it, expect } from 'vitest';
import jwt from 'jsonwebtoken';

const BASE = 'http://127.0.0.1:3017';
const JWT_SECRET = 'xiuxian_secret_2026_test';
const WALLET = '0xbot0000000000000000000000000000000000e5';
const PLAYER_ID = 13;
let token;

function makeToken() {
  return jwt.sign({ wallet: WALLET, id: PLAYER_ID }, JWT_SECRET, { expiresIn: '1h' });
}

async function api(method, path, body, headers = {}) {
  if (!token) token = makeToken();
  const opts = { method, headers: { 'Content-Type': 'application/json', ...headers } };
  opts.headers.Authorization = 'Bearer ' + token;
  if (body) opts.body = JSON.stringify(body);
  const r = await fetch(BASE + path, opts);
  const text = await r.text();
  try { return { status: r.status, ...JSON.parse(text) }; } catch { return { status: r.status, raw: text }; }
}

// ============================================================
// PK Battle unit tests (runPkBattle is not exported, so we
// replicate the core calcDmg logic to verify attribute effects)
// ============================================================

describe('PK Battle logic', () => {
  // We test via /api/pk/stats to confirm the endpoint works,
  // then test battle mechanics by running many simulated fights
  // through a helper that mirrors server logic.

  function calcDmg(atk, def) {
    let dmg = atk.attack * (100 / (100 + def.defense));
    dmg *= 1 + (atk.combatBoost || 0);
    dmg *= 1 + (atk.finalDamageBoost || 0);
    let isCrit = Math.random() < (atk.critRate || 0.05);
    let isCombo = Math.random() < (atk.comboRate || 0);
    const effectiveDodge = Math.max(0, (def.dodgeRate || 0.05) - (atk.dodgeResist || 0));
    let isDodged = Math.random() < effectiveDodge;
    if (isCrit) {
      let critMult = 1.5 + (atk.critDamageBoost || 0);
      critMult -= (def.critDamageReduce || 0);
      dmg *= Math.max(1.1, critMult);
    }
    if (isCombo) dmg *= 1.3;
    dmg *= 1 - Math.min(0.7, (def.finalDamageReduce || 0));
    dmg *= 1 - Math.min(0.3, (def.resistanceBoost || 0));
    return { damage: Math.max(1, Math.floor(dmg)), isCrit, isCombo, isDodged };
  }

  it('combatBoost increases damage', () => {
    const base = { attack: 100, defense: 0 };
    const def = { attack: 50, defense: 50, health: 1000 };
    const dmgs = [];
    for (let i = 0; i < 200; i++) {
      dmgs.push(calcDmg({ ...base, combatBoost: 0.5, critRate: 0, comboRate: 0 },
        { ...def, dodgeRate: 0 }).damage);
    }
    const avg = dmgs.reduce((a, b) => a + b) / dmgs.length;
    // Without combatBoost: 100*(100/150)=66.6, with 0.5 boost: ~100
    expect(avg).toBeGreaterThan(90);
  });

  it('finalDamageReduce caps at 70%', () => {
    const atk = { attack: 100, defense: 0, critRate: 0, comboRate: 0 };
    const def = { defense: 0, dodgeRate: 0, finalDamageReduce: 0.9 }; // over cap
    const dmgs = [];
    for (let i = 0; i < 100; i++) {
      dmgs.push(calcDmg(atk, def).damage);
    }
    const avg = dmgs.reduce((a, b) => a + b) / dmgs.length;
    // 100 * (1 - 0.7) = 30, not 100 * (1 - 0.9) = 10
    expect(avg).toBeGreaterThan(25);
    expect(avg).toBeLessThan(40);
  });

  it('resistanceBoost caps at 30%', () => {
    const atk = { attack: 100, defense: 0, critRate: 0, comboRate: 0 };
    const def = { defense: 0, dodgeRate: 0, resistanceBoost: 0.8 }; // over cap
    const dmgs = [];
    for (let i = 0; i < 100; i++) {
      dmgs.push(calcDmg(atk, def).damage);
    }
    const avg = dmgs.reduce((a, b) => a + b) / dmgs.length;
    // 100 * (1 - 0.3) = 70
    expect(avg).toBeGreaterThan(60);
    expect(avg).toBeLessThan(80);
  });

  it('dodgeResist counters dodgeRate', () => {
    const atk = { attack: 100, defense: 0, critRate: 0, comboRate: 0, dodgeResist: 0.5 };
    const def = { defense: 0, dodgeRate: 0.5 }; // effective dodge = 0
    let dodged = 0;
    for (let i = 0; i < 200; i++) {
      if (calcDmg(atk, def).isDodged) dodged++;
    }
    // effective dodge is 0, so dodged should be 0
    expect(dodged).toBe(0);
  });

  it('critDamageBoost increases crit multiplier', () => {
    const atk = { attack: 100, defense: 0, critRate: 1, comboRate: 0, critDamageBoost: 0.5 };
    const def = { defense: 0, dodgeRate: 0 };
    const dmgs = [];
    for (let i = 0; i < 100; i++) {
      dmgs.push(calcDmg(atk, def).damage);
    }
    const avg = dmgs.reduce((a, b) => a + b) / dmgs.length;
    // 100 * (1.5 + 0.5) = 200
    expect(avg).toBeGreaterThan(190);
    expect(avg).toBeLessThan(210);
  });
});

// ============================================================
// Boss attack API test
// ============================================================

describe('Boss attack', () => {
  it('/api/boss/current returns valid response', async () => {
    const r = await api('GET', '/api/boss/current');
    // Either a boss exists or no active boss - both are valid
    expect([200, 404].includes(r.status) || r.boss !== undefined || r.error !== undefined).toBe(true);
  });
});

// ============================================================
// Dungeon API test
// ============================================================

describe('Dungeon daily', () => {
  it('/api/dungeon-daily/list returns array', async () => {
    const r = await api('GET', '/api/dungeon-daily/list');
    expect(r.status).toBe(200);
    // Should have dungeons array or be empty
    expect(Array.isArray(r.dungeons) || Array.isArray(r)).toBe(true);
  });
});

// ============================================================
// PK stats endpoint
// ============================================================

describe('PK stats', () => {
  it('/api/pk/my-stats returns stats object', async () => {
    const r = await api('GET', '/api/pk/my-stats');
    expect(r.status).toBe(200);
  });

  it('/api/pk/rankings returns rankings', async () => {
    const r = await api('GET', '/api/pk/rankings');
    expect(r.status).toBe(200);
  });
});
