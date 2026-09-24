const { Pool } = require('pg');
require('dotenv').config();

const pool = new Pool({
  user: process.env.DB_USER,
  host: process.env.DB_HOST,
  database: process.env.DB_NAME,
  password: process.env.DB_PASSWORD,
  port: parseInt(process.env.DB_PORT || '5432'),
  ssl: { rejectUnauthorized: false }
});

async function main() {
  try {
    await pool.query('ALTER TABLE users ADD COLUMN IF NOT EXISTS fcm_token TEXT;');
    await pool.query('ALTER TABLE app_sellers ADD COLUMN IF NOT EXISTS fcm_token TEXT;');
    console.log('✅ Successfully added fcm_token columns to Supabase database.');
  } catch (err) {
    console.error('❌ Error adding columns:', err);
  } finally {
    process.exit();
  }
}

main();
