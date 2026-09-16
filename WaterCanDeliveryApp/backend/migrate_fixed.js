const dotenv = require('dotenv');
dotenv.config();

const { Pool } = require('pg');

const pool = new Pool({
  user: process.env.DB_USER?.trim(),
  host: process.env.DB_HOST?.trim(),
  database: process.env.DB_NAME?.trim(),
  password: process.env.DB_PASSWORD?.trim(),
  port: parseInt(process.env.DB_PORT?.trim() || '5432', 10),
  ssl: { rejectUnauthorized: false },
});

async function runMigration() {
  try {
    await pool.query(`ALTER TABLE app_orders ADD COLUMN is_fast_delivery BOOLEAN DEFAULT false`);
    console.log('Migration successful: Added is_fast_delivery column.');
  } catch (err) {
    if (err.code === '42701') {
      console.log('Migration skipped: Column already exists.');
    } else {
      console.error('Migration failed:', err);
    }
  } finally {
    pool.end();
  }
}

runMigration();
