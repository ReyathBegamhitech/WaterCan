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

const sql = `
SELECT 
  s.seller_id, 
  COUNT(o.id) as overall_orders,
  SUM(CASE WHEN o.status IN ('Placed', 'Accepted', 'Out for Delivery') THEN 1 ELSE 0 END) as orders_in_process,
  SUM(CASE WHEN EXTRACT(MONTH FROM o.created_at) = EXTRACT(MONTH FROM CURRENT_DATE) AND EXTRACT(YEAR FROM o.created_at) = EXTRACT(YEAR FROM CURRENT_DATE) THEN 1 ELSE 0 END) as monthly_orders
FROM app_sellers s
LEFT JOIN app_orders o ON s.seller_id = o.seller_id
GROUP BY s.seller_id
`;

pool.query(sql)
  .then(r => console.log('Query result:', r.rows))
  .catch(console.error)
  .finally(() => pool.end());
