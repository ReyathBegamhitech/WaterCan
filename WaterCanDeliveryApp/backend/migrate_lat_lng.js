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
    await pool.query(`ALTER TABLE app_orders ADD COLUMN latitude NUMERIC`);
    await pool.query(`ALTER TABLE app_orders ADD COLUMN longitude NUMERIC`);
    console.log('Added latitude and longitude to app_orders');
  } catch (err) {
    console.log('Skipped app_orders migration:', err.message);
  }
  
  try {
    await pool.query(`ALTER TABLE addresses ADD COLUMN latitude NUMERIC`);
    await pool.query(`ALTER TABLE addresses ADD COLUMN longitude NUMERIC`);
    console.log('Added latitude and longitude to addresses');
  } catch (err) {
    console.log('Skipped addresses migration:', err.message);
  }

  pool.end();
}

runMigration();
