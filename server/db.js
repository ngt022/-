import pg from 'pg'

const pool = new pg.Pool({
  user: 'roon_user',
  password: 'RoonG@ming2026!',
  host: 'localhost',
  port: 5432,
  database: "xiuxian",
  max: 20
})

export default pool
