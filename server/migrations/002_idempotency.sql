-- M3: Idempotency + distributed lock support (PostgreSQL-based, no Redis needed)

-- Idempotency cache table
CREATE TABLE IF NOT EXISTS idempotency_cache (
  key         VARCHAR(200) PRIMARY KEY,
  status_code INT NOT NULL,
  response    JSONB NOT NULL,
  created_at  TIMESTAMPTZ DEFAULT now()
);

-- Auto-cleanup index for TTL
CREATE INDEX IF NOT EXISTS idx_idem_created ON idempotency_cache(created_at);

-- Cleanup function: delete entries older than 10 minutes
-- Run periodically or on each check
