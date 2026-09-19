import pool from './src/config/db';

async function alterTable() {
  try {
    await pool.query('ALTER TABLE app_sellers ADD COLUMN IF NOT EXISTS plain_password VARCHAR(255)');
    console.log('Column plain_password added');
  } catch (err) {
    console.error(err);
  } finally {
    pool.end();
  }
}

alterTable();
