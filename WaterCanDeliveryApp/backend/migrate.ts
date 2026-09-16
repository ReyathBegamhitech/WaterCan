import pool from './src/config/db';

async function runMigration() {
  try {
    await pool.query(`ALTER TABLE app_orders ADD COLUMN is_fast_delivery BOOLEAN DEFAULT false`);
    console.log('Migration successful: Added is_fast_delivery column.');
  } catch (err: any) {
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
