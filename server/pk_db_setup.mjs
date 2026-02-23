import pg from 'pg';
const pool = new pg.Pool({connectionString:'postgresql://roon_user:RoonG@ming2026!@127.0.0.1/xiuxian'});

// 1. 建 pk_rankings 表
await pool.query(`
CREATE TABLE IF NOT EXISTS pk_rankings (
  id SERIAL PRIMARY KEY,
  wallet VARCHAR(42) UNIQUE NOT NULL,
  rank_score INT DEFAULT 1000,
  rank_tier VARCHAR(20) DEFAULT 'silver',
  season INT DEFAULT 1,
  wins INT DEFAULT 0,
  losses INT DEFAULT 0,
  draws INT DEFAULT 0,
  win_streak INT DEFAULT 0,
  max_win_streak INT DEFAULT 0,
  last_pk_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_pk_rankings_score ON pk_rankings(rank_score DESC);
CREATE INDEX IF NOT EXISTS idx_pk_rankings_season ON pk_rankings(season);
`);
console.log('pk_rankings table created');

// 2. pk_records 加字段
await pool.query(`ALTER TABLE pk_records ADD COLUMN IF NOT EXISTS bet_amount INT DEFAULT 0`);
await pool.query(`ALTER TABLE pk_records ADD COLUMN IF NOT EXISTS score_change_a INT DEFAULT 0`);
await pool.query(`ALTER TABLE pk_records ADD COLUMN IF NOT EXISTS score_change_b INT DEFAULT 0`);
console.log('pk_records columns added');

// 3. 两个库都建
const pool2 = new pg.Pool({connectionString:'postgresql://roon_user:RoonG@ming2026!@127.0.0.1/xiuxian_test'});
await pool2.query(`
CREATE TABLE IF NOT EXISTS pk_rankings (
  id SERIAL PRIMARY KEY,
  wallet VARCHAR(42) UNIQUE NOT NULL,
  rank_score INT DEFAULT 1000,
  rank_tier VARCHAR(20) DEFAULT 'silver',
  season INT DEFAULT 1,
  wins INT DEFAULT 0,
  losses INT DEFAULT 0,
  draws INT DEFAULT 0,
  win_streak INT DEFAULT 0,
  max_win_streak INT DEFAULT 0,
  last_pk_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_pk_rankings_score ON pk_rankings(rank_score DESC);
CREATE INDEX IF NOT EXISTS idx_pk_rankings_season ON pk_rankings(season);
`);
await pool2.query(`ALTER TABLE pk_records ADD COLUMN IF NOT EXISTS bet_amount INT DEFAULT 0`);
await pool2.query(`ALTER TABLE pk_records ADD COLUMN IF NOT EXISTS score_change_a INT DEFAULT 0`);
await pool2.query(`ALTER TABLE pk_records ADD COLUMN IF NOT EXISTS score_change_b INT DEFAULT 0`);
console.log('test db done too');

await pool.end();
await pool2.end();
console.log('All done');
