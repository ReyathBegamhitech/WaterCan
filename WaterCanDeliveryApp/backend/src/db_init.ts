import pool from './config/db';

async function init() {
  try {
    await pool.query(`
      CREATE TABLE IF NOT EXISTS app_orders (
        id SERIAL PRIMARY KEY,
        user_phone VARCHAR(20),
        buyer_name VARCHAR(100),
        buyer_phone VARCHAR(20),
        shop_name VARCHAR(200),
        quantity INTEGER,
        price_per_can NUMERIC,
        total_price NUMERIC,
        status VARCHAR(50) DEFAULT 'Placed',
        time VARCHAR(50),
        delivery_address TEXT,
        latitude NUMERIC,
        longitude NUMERIC,
        order_details JSONB,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);
    console.log('Orders table created successfully');
  } catch (error) {
    console.error('Error creating orders table:', error);
  } finally {
    pool.end();
  }
}

init();
