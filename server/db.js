import dotenv from 'dotenv';
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';

const __dirname = dirname(fileURLToPath(import.meta.url));

// 按优先级加载: .env.{GAME_ENV} > .env
const env = process.env.GAME_ENV || 'production';
dotenv.config({ path: join(__dirname, '.env.' + env) });
dotenv.config({ path: join(__dirname, '.env') });

import pg from 'pg'

const pool = new pg.Pool({
  connectionString: process.env.DATABASE_URL || 'postgresql://roon_user:RoonG%40ming2026!@localhost:5432/xiuxian',
  max: 20,
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 5000,
})

const dbName = (process.env.DATABASE_URL || '').split('/').pop() || 'xiuxian';
console.log('[DB] pool → ' + dbName + ' (env: ' + env + ')');

export default pool
