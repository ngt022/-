import dotenv from 'dotenv';
dotenv.config({ path: new URL('./.env', import.meta.url).pathname });

import pg from 'pg'

const pool = new pg.Pool({
  user: 'roon_user',
  password: process.env.DB_PASSWORD || 'changeme',
  host: 'localhost',
  port: 5432,
  database: "xiuxian",
  max: 20
})

export default pool
