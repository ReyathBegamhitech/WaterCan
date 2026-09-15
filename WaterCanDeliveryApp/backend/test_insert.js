const { Pool } = require('pg');
require('dotenv').config();

const pool = new Pool({
  connectionString: process.env.DATABASE_URL || 'postgres://' + process.env.DB_USER + ':' + process.env.DB_PASSWORD + '@' + process.env.DB_HOST + ':' + process.env.DB_PORT + '/' + process.env.DB_NAME,
  ssl: { rejectUnauthorized: false }
});

async function run() {
  try {
    const result = await pool.query(
      'INSERT INTO orders (user_phone, buyer_name, buyer_phone, shop_name, quantity, price_per_can, total_price, time) VALUES ($1, $2, $3, $4, $5, $6, $7, $8) RETURNING *',
      ['123', 'test', '123', 'test', 1, 10, 10, 'now']
    );
    console.log('Success:', result.rows);
  } catch (err) {
    console.error('Error:', err);
  } finally {
    pool.end();
  }
}

run();
