-- 火之文明 xiuxian_game schema
-- Created: 2026-02-19

-- 用户表
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  wallet_address VARCHAR(42) UNIQUE NOT NULL,
  nickname VARCHAR(50) DEFAULT '无名修士',
  nickname_changes INT DEFAULT 0,
  created_at TIMESTAMP DEFAULT NOW(),
  last_login TIMESTAMP DEFAULT NOW(),
  is_banned BOOLEAN DEFAULT FALSE
);

-- 玩家数据表（核心属性）
CREATE TABLE player_data (
  id SERIAL PRIMARY KEY,
  user_id INT UNIQUE REFERENCES users(id) ON DELETE CASCADE,
  level INT DEFAULT 1,
  realm VARCHAR(50) DEFAULT '燃火期一层',
  cultivation BIGINT DEFAULT 0,
  max_cultivation BIGINT DEFAULT 100,
  spirit BIGINT DEFAULT 0,
  spirit_rate DECIMAL(10,4) DEFAULT 1.0,
  luck DECIMAL(10,4) DEFAULT 1.0,
  cultivation_rate DECIMAL(10,4) DEFAULT 1.0,
  herb_rate DECIMAL(10,4) DEFAULT 1.0,
  alchemy_rate DECIMAL(10,4) DEFAULT 1.0,
  spirit_stones BIGINT DEFAULT 0,
  reinforce_stones BIGINT DEFAULT 0,
  refinement_stones BIGINT DEFAULT 0,
  pet_essence BIGINT DEFAULT 0,
  base_attack INT DEFAULT 10,
  base_health INT DEFAULT 100,
  base_defense INT DEFAULT 5,
  base_speed INT DEFAULT 10,
  crit_rate DECIMAL(10,6) DEFAULT 0,
  combo_rate DECIMAL(10,6) DEFAULT 0,
  counter_rate DECIMAL(10,6) DEFAULT 0,
  stun_rate DECIMAL(10,6) DEFAULT 0,
  dodge_rate DECIMAL(10,6) DEFAULT 0,
  vampire_rate DECIMAL(10,6) DEFAULT 0,
  crit_resist DECIMAL(10,6) DEFAULT 0,
  combo_resist DECIMAL(10,6) DEFAULT 0,
  counter_resist DECIMAL(10,6) DEFAULT 0,
  stun_resist DECIMAL(10,6) DEFAULT 0,
  dodge_resist DECIMAL(10,6) DEFAULT 0,
  vampire_resist DECIMAL(10,6) DEFAULT 0,
  heal_boost DECIMAL(10,6) DEFAULT 0,
  crit_damage_boost DECIMAL(10,6) DEFAULT 0,
  crit_damage_reduce DECIMAL(10,6) DEFAULT 0,
  final_damage_boost DECIMAL(10,6) DEFAULT 0,
  final_damage_reduce DECIMAL(10,6) DEFAULT 0,
  combat_boost DECIMAL(10,6) DEFAULT 0,
  resistance_boost DECIMAL(10,6) DEFAULT 0,
  breakthrough_count INT DEFAULT 0,
  exploration_count INT DEFAULT 0,
  items_found INT DEFAULT 0,
  pills_crafted INT DEFAULT 0,
  pills_consumed INT DEFAULT 0,
  dungeon_highest_floor INT DEFAULT 0,
  dungeon_total_runs INT DEFAULT 0,
  dungeon_boss_kills INT DEFAULT 0,
  last_online_time BIGINT DEFAULT 0,
  is_auto_cultivating BOOLEAN DEFAULT FALSE,
  updated_at TIMESTAMP DEFAULT NOW()
);

-- 装备表
CREATE TABLE equipment (
  id SERIAL PRIMARY KEY,
  owner_id INT REFERENCES users(id) ON DELETE CASCADE,
  name VARCHAR(100) NOT NULL,
  type VARCHAR(20) NOT NULL,
  slot VARCHAR(20) NOT NULL,
  quality VARCHAR(20) NOT NULL,
  level INT DEFAULT 1,
  required_realm INT DEFAULT 1,
  enhance_level INT DEFAULT 0,
  stats JSONB NOT NULL DEFAULT '{}',
  is_equipped BOOLEAN DEFAULT FALSE,
  equipped_slot VARCHAR(20),
  created_at TIMESTAMP DEFAULT NOW()
);
CREATE INDEX idx_equipment_owner ON equipment(owner_id);
CREATE INDEX idx_equipment_equipped ON equipment(owner_id, is_equipped);

-- 焰兽表
CREATE TABLE pets (
  id SERIAL PRIMARY KEY,
  owner_id INT REFERENCES users(id) ON DELETE CASCADE,
  name VARCHAR(50) NOT NULL,
  description TEXT,
  rarity VARCHAR(20) NOT NULL,
  level INT DEFAULT 1,
  star INT DEFAULT 0,
  is_active BOOLEAN DEFAULT FALSE,
  combat_attributes JSONB NOT NULL DEFAULT '{}',
  created_at TIMESTAMP DEFAULT NOW()
);
CREATE INDEX idx_pets_owner ON pets(owner_id);

-- 焰草表
CREATE TABLE herbs (
  id SERIAL PRIMARY KEY,
  owner_id INT REFERENCES users(id) ON DELETE CASCADE,
  herb_id VARCHAR(50) NOT NULL,
  name VARCHAR(50) NOT NULL,
  quality VARCHAR(20) NOT NULL,
  value INT DEFAULT 0,
  created_at TIMESTAMP DEFAULT NOW()
);
CREATE INDEX idx_herbs_owner ON herbs(owner_id);

-- 焰丹表
CREATE TABLE pills (
  id SERIAL PRIMARY KEY,
  owner_id INT REFERENCES users(id) ON DELETE CASCADE,
  recipe_id VARCHAR(50) NOT NULL,
  name VARCHAR(50) NOT NULL,
  description TEXT,
  effect JSONB NOT NULL DEFAULT '{}',
  created_at TIMESTAMP DEFAULT NOW()
);
CREATE INDEX idx_pills_owner ON pills(owner_id);

-- 焰丹配方
CREATE TABLE pill_recipes (
  id SERIAL PRIMARY KEY,
  user_id INT REFERENCES users(id) ON DELETE CASCADE,
  recipe_id VARCHAR(50) NOT NULL,
  UNIQUE(user_id, recipe_id)
);

-- 焰丹残页
CREATE TABLE pill_fragments (
  id SERIAL PRIMARY KEY,
  user_id INT REFERENCES users(id) ON DELETE CASCADE,
  recipe_id VARCHAR(50) NOT NULL,
  count INT DEFAULT 0,
  UNIQUE(user_id, recipe_id)
);

-- 成就表
CREATE TABLE achievements (
  id SERIAL PRIMARY KEY,
  user_id INT REFERENCES users(id) ON DELETE CASCADE,
  achievement_id VARCHAR(50) NOT NULL,
  completed_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(user_id, achievement_id)
);

-- 活跃效果
CREATE TABLE active_effects (
  id SERIAL PRIMARY KEY,
  user_id INT REFERENCES users(id) ON DELETE CASCADE,
  effect_type VARCHAR(50) NOT NULL,
  effect_value DECIMAL(10,4) NOT NULL,
  start_time BIGINT NOT NULL,
  end_time BIGINT NOT NULL
);
CREATE INDEX idx_effects_user ON active_effects(user_id);
