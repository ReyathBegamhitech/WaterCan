import pool from './src/config/db';

async function testInsert() {
  try {
    const result = await pool.query(
      `INSERT INTO app_orders (user_phone, buyer_name, buyer_phone, shop_name, quantity, price_per_can, total_price, time, delivery_address, order_details) 
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10) RETURNING *`,
      ['9999999999', 'Test Buyer', '9999999999', 'Test Shop', 1, 10, 10, 'today', 'test address', JSON.stringify([{ id: 1 }])]
    );
    console.log('Insert successful:', result.rows);
  } catch (err) {
    console.error('Insert failed:', err);
  } finally {
    pool.end();
  }
}

testInsert();
