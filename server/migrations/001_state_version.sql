-- M1: Add state_version to players for SSOT tracking
-- Every mutation that affects combat-relevant state increments this counter.

ALTER TABLE players ADD COLUMN IF NOT EXISTS state_version BIGINT DEFAULT 0;

-- Snapshot table for M2 (create now so M1 code can reference it)
CREATE TABLE IF NOT EXISTS player_stats_snapshot (
  player_id   INT PRIMARY KEY REFERENCES players(id),
  state_version BIGINT NOT NULL DEFAULT 0,
  final_stats JSONB NOT NULL DEFAULT '{}',
  computed_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_snapshot_version ON player_stats_snapshot(player_id, state_version);

-- Battle trace log (optional, for observability)
CREATE TABLE IF NOT EXISTS battle_trace_log (
  id          BIGSERIAL PRIMARY KEY,
  battle_type VARCHAR(20) NOT NULL,  -- pk, boss, dungeon, sect_war
  player_a_wallet VARCHAR(42),
  player_b_wallet VARCHAR(42),
  player_a_version BIGINT,
  player_b_version BIGINT,
  stats_a     JSONB,
  stats_b     JSONB,
  result      JSONB,
  created_at  TIMESTAMPTZ DEFAULT now()
);

-- Auto-cleanup: keep only 7 days of battle traces
-- (run via cron or manually: DELETE FROM battle_trace_log WHERE created_at < now() - interval '7 days')
