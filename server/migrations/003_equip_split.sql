-- M4: Equipment DB split — move equipment from game_data JSONB to relational tables
-- Strategy: new tables + migration script, dual-write during transition

-- Item instances (all equipment, whether in bag or equipped)
CREATE TABLE IF NOT EXISTS inventory_items (
  id            BIGSERIAL PRIMARY KEY,
  player_id     INT NOT NULL REFERENCES players(id),
  original_id   TEXT,                          -- original game_data item id (for migration mapping)
  name          VARCHAR(100) NOT NULL,
  type          VARCHAR(50) NOT NULL,          -- weapon/head/body/feet/ring/necklace
  quality       VARCHAR(50) DEFAULT 'common',  -- common/uncommon/rare/epic/legendary/mythic
  stats         JSONB NOT NULL DEFAULT '{}',
  attributes    JSONB DEFAULT '{}',
  enhance_level INT DEFAULT 0,
  required_realm INT DEFAULT 0,
  source        VARCHAR(50) DEFAULT 'unknown', -- gacha/drop/craft/quest
  created_at    TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_inv_player ON inventory_items(player_id);
CREATE INDEX IF NOT EXISTS idx_inv_original ON inventory_items(original_id);

-- Equipment slots (what's currently worn)
CREATE TABLE IF NOT EXISTS equip_slots (
  id            SERIAL PRIMARY KEY,
  player_id     INT NOT NULL REFERENCES players(id),
  slot          VARCHAR(50) NOT NULL,          -- weapon/head/body/feet/ring/necklace
  item_id       BIGINT REFERENCES inventory_items(id),
  updated_at    TIMESTAMPTZ DEFAULT now(),
  UNIQUE(player_id, slot)
);

CREATE INDEX IF NOT EXISTS idx_equip_player ON equip_slots(player_id);
