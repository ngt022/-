/**
 * lock-service.js — Distributed lock + Idempotency using PostgreSQL advisory locks.
 * No Redis needed. Uses pg_advisory_xact_lock for per-transaction locks
 * and an idempotency_cache table for replay protection.
 */

// Convert string key to a 64-bit integer for pg_advisory_lock
function hashKey(str) {
  let h = 0n;
  for (let i = 0; i < str.length; i++) {
    h = ((h << 5n) - h + BigInt(str.charCodeAt(i))) & 0xFFFFFFFFFFFFFFFFn;
  }
  // pg_advisory_lock takes two int4 or one int8; use two int4
  const hi = Number((h >> 32n) & 0x7FFFFFFFn);
  const lo = Number(h & 0x7FFFFFFFn);
  return [hi, lo];
}

/**
 * Try to acquire a session-level advisory lock (non-blocking).
 * Returns true if acquired, false if already held by another session.
 */
export async function tryLock(pool, lockKey) {
  const [hi, lo] = hashKey(lockKey);
  const r = await pool.query('SELECT pg_try_advisory_lock($1, $2) as acquired', [hi, lo]);
  return r.rows[0].acquired;
}

/**
 * Release a session-level advisory lock.
 */
export async function releaseLock(pool, lockKey) {
  const [hi, lo] = hashKey(lockKey);
  await pool.query('SELECT pg_advisory_unlock($1, $2)', [hi, lo]);
}

/**
 * Transaction-level advisory lock (auto-released on COMMIT/ROLLBACK).
 * Use inside a transaction with a client from pool.connect().
 */
export async function txLock(client, lockKey) {
  const [hi, lo] = hashKey(lockKey);
  const r = await client.query('SELECT pg_try_advisory_xact_lock($1, $2) as acquired', [hi, lo]);
  return r.rows[0].acquired;
}

/**
 * Check idempotency cache. Returns cached response or null.
 */
export async function getIdempotencyCache(pool, key) {
  // Cleanup old entries (> 10 min) opportunistically
  pool.query("DELETE FROM idempotency_cache WHERE created_at < now() - interval '10 minutes'").catch(() => {});
  
  const r = await pool.query('SELECT status_code, response FROM idempotency_cache WHERE key=$1', [key]);
  if (r.rows.length) {
    return { statusCode: r.rows[0].status_code, response: r.rows[0].response };
  }
  return null;
}

/**
 * Write idempotency cache.
 */
export async function setIdempotencyCache(pool, key, statusCode, response) {
  try {
    await pool.query(
      'INSERT INTO idempotency_cache (key, status_code, response) VALUES ($1, $2, $3) ON CONFLICT (key) DO NOTHING',
      [key, statusCode, JSON.stringify(response)]
    );
  } catch(e) {
    console.error('[Idempotency] cache write failed:', e.message);
  }
}

/**
 * Express middleware: idempotency + distributed lock for mutation endpoints.
 * 
 * Usage: app.post('/api/equip/wear', auth, idempotent(pool, 'wear'), handler)
 * 
 * Requires header `Idempotency-Key` or body `requestId`.
 * If missing, returns 400.
 * If duplicate, returns cached response.
 * Also acquires a per-player advisory lock; if lock busy, returns 409.
 */
export function idempotent(pool, action) {
  return async (req, res, next) => {
    const idemKey = req.headers['idempotency-key'] || req.body?.requestId;
    if (!idemKey) {
      return res.status(400).json({ error: '缺少 Idempotency-Key 或 requestId' });
    }

    const wallet = req.user?.wallet;
    if (!wallet) return next(); // no auth, skip

    const cacheKey = `idem:${wallet}:${action}:${idemKey}`;

    // Check cache
    const cached = await getIdempotencyCache(pool, cacheKey);
    if (cached) {
      return res.status(cached.statusCode).json(cached.response);
    }

    // Try lock
    const lockKey = `lock:${wallet}:${action}`;
    const acquired = await tryLock(pool, lockKey);
    if (!acquired) {
      return res.status(409).json({ error: '操作冲突，请稍后重试' });
    }

    // Store original res.json to intercept response
    const origJson = res.json.bind(res);
    res.json = (body) => {
      // Cache the response
      setIdempotencyCache(pool, cacheKey, res.statusCode || 200, body).catch(() => {});
      // Release lock
      releaseLock(pool, lockKey).catch(() => {});
      return origJson(body);
    };

    // Also release lock on error
    const origStatus = res.status.bind(res);
    const cleanup = () => { releaseLock(pool, lockKey).catch(() => {}); };
    res.on('finish', cleanup);

    next();
  };
}
