require('dotenv').config();
const { Pool } = require('pg');

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
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
