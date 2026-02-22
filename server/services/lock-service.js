/**
 * lock-service.js — Idempotency middleware using PostgreSQL.
 * Row-level locking (FOR UPDATE) in wear/unwear/enhance already handles concurrency.
 * This middleware only handles idempotency cache (replay protection).
 */

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
 * Express middleware: idempotency for mutation endpoints.
 * 
 * Usage: app.post('/api/equip/wear', auth, idempotent(pool, 'wear'), handler)
 * 
 * Requires header `Idempotency-Key` or body `requestId`.
 * If missing, passes through (no enforcement — allows backward compat).
 * If duplicate, returns cached response.
 */
export function idempotent(pool, action) {
  return async (req, res, next) => {
    const idemKey = req.headers['idempotency-key'] || req.body?.requestId;
    if (!idemKey) {
      // No key provided — skip idempotency, let request through
      return next();
    }

    const wallet = req.user?.wallet;
    if (!wallet) return next();

    const cacheKey = `idem:${wallet}:${action}:${idemKey}`;

    // Check cache
    const cached = await getIdempotencyCache(pool, cacheKey);
    if (cached) {
      return res.status(cached.statusCode).json(cached.response);
    }

    // Intercept res.json to cache the response
    const origJson = res.json.bind(res);
    res.json = (body) => {
      setIdempotencyCache(pool, cacheKey, res.statusCode || 200, body).catch(() => {});
      return origJson(body);
    };

    next();
  };
}

// Keep these exports for backward compat but they're no-ops now
export async function tryLock() { return true; }
export async function releaseLock() {}
export async function txLock() { return true; }
