const { Pool } = require('pg');
require('dotenv').config();
const pool = new Pool({
  user: process.env.DB_USER?.trim(),
  host: process.env.DB_HOST?.trim(),
  database: process.env.DB_NAME?.trim(),
  password: process.env.DB_PASSWORD?.trim(),
  port: parseInt(process.env.DB_PORT?.trim() || '5432', 10),
  ssl: { rejectUnauthorized: false },
});
pool.query("UPDATE users SET assigned_seller_id = 'S-1001' WHERE assigned_seller_id IS NULL OR assigned_seller_id = '' RETURNING phone_number")
  .then(r => console.log('Updated users:', r.rows))
  .catch(console.error)
  .finally(() => pool.end());
