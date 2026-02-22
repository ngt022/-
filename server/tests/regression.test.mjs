import { describe, it, expect, beforeAll, beforeEach } from 'vitest';
import jwt from 'jsonwebtoken';

const BASE = 'http://127.0.0.1:3017';
const JWT_SECRET = 'xiuxian_secret_2026_test';
const WALLET = '0xbot0000000000000000000000000000000000e5';
const PLAYER_ID = 13;

let token;

async function api(method, path, body, headers = {}) {
  const opts = { method, headers: { 'Content-Type': 'application/json', ...headers } };
  if (token) opts.headers.Authorization = 'Bearer ' + token;
  if (body) opts.body = JSON.stringify(body);
  const r = await fetch(BASE + path, opts);
  const text = await r.text();
  try { return { status: r.status, ...JSON.parse(text) }; }
  catch { return { status: r.status, raw: text }; }
}

function idemKey() { return 'test-' + Date.now() + '-' + Math.random(); }

async function cleanSlots() {
  const r = await api('GET', '/api/game/load');
  const eq = r.player?.gameData?.equippedArtifacts || {};
  for (const s of Object.keys(eq)) {
    if (eq[s]) await api('POST', '/api/equip/unwear', { slot: s });
  }
}

async function getWearableItem() {
  const r = await api('GET', '/api/game/load');
  const items = r.player?.gameData?.items || [];
  return items.find(i => i.stats && i.type && !['pill', 'pet', 'herb'].includes(i.type));
}

beforeAll(() => {
  token = jwt.sign({ wallet: WALLET, id: PLAYER_ID }, JWT_SECRET, { expiresIn: '1h' });
});

describe('Load', () => {
  it('returns player with gameData and stateVersion', async () => {
    const r = await api('GET', '/api/game/load');
    expect(r.player).toBeDefined();
    expect(r.player.stateVersion).toBeTypeOf('number');
    expect(r.player.gameData.baseAttributes).toBeDefined();
  });
});

describe('Equipment wear/unwear', () => {
  beforeEach(async () => { await cleanSlots(); });

  it('wear and unwear increment state_version', async () => {
    const load = await api('GET', '/api/game/load');
    const sv0 = load.player.stateVersion;
    const item = await getWearableItem();
    expect(item).toBeDefined();

    const wear = await api('POST', '/api/equip/wear', { equipId: item.id, slot: item.type });
    expect(wear.success).toBe(true);
    expect(wear.state_version).toBe(sv0 + 1);

    const unwear = await api('POST', '/api/equip/unwear', { slot: item.type });
    expect(unwear.success).toBe(true);
    expect(unwear.state_version).toBe(sv0 + 2);
  });

  it('20 wear/unwear cycles: no atk drift', async () => {
    const item = await getWearableItem();
    expect(item).toBeDefined();
    const slot = item.type;
    const itemId = item.id;

    await api('POST', '/api/equip/wear', { equipId: itemId, slot });
    const baseline = await api('GET', '/api/game/load');
    const refAtk = baseline.player.gameData.baseAttributes.attack;
    await api('POST', '/api/equip/unwear', { slot });

    for (let i = 0; i < 20; i++) {
      await api('POST', '/api/equip/wear', { equipId: itemId, slot });
      const ld = await api('GET', '/api/game/load');
      expect(ld.player.gameData.baseAttributes.attack).toBe(refAtk);
      await api('POST', '/api/equip/unwear', { slot });
    }
  }, 30000);
});

describe('Idempotency', () => {
  beforeEach(async () => { await cleanSlots(); });

  it('without key: request still works (backward compat)', async () => {
    const item = await getWearableItem();
    expect(item).toBeDefined();
    const r = await api('POST', '/api/equip/wear', { equipId: item.id, slot: item.type });
    expect(r.success).toBe(true);
  });

  it('replays same key with cached response', async () => {
    const item = await getWearableItem();
    expect(item).toBeDefined();

    const key = idemKey();
    const r1 = await api('POST', '/api/equip/wear',
      { equipId: item.id, slot: item.type }, { 'Idempotency-Key': key });
    expect(r1.success).toBe(true);

    const r2 = await api('POST', '/api/equip/wear',
      { equipId: item.id, slot: item.type }, { 'Idempotency-Key': key });
    expect(r2.state_version).toBe(r1.state_version);
  });
});

describe('Save', () => {
  it('save increments state_version', async () => {
    const load = await api('GET', '/api/game/load');
    const sv = load.player.stateVersion;
    const gd = load.player.gameData;
    const r = await api('POST', '/api/game/save', { gameData: gd });
    expect(r.ok).toBe(true);

    const load2 = await api('GET', '/api/game/load');
    expect(load2.player.stateVersion).toBe(sv + 1);
  });
});

describe('Read consistency', () => {
  it('5 consecutive loads return same atk', async () => {
    const reads = [];
    for (let i = 0; i < 5; i++) {
      const r = await api('GET', '/api/game/load');
      reads.push(r.player.gameData.baseAttributes.attack);
    }
    expect(new Set(reads).size).toBe(1);
  });
});
