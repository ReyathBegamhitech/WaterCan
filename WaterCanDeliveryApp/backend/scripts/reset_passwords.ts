import pool from '../src/config/db';
import bcrypt from 'bcrypt';

async function run() {
  try {
    const res = await pool.query('SELECT seller_id FROM app_sellers WHERE plain_password IS NULL');
    const sellers = res.rows;
    console.log(`Found ${sellers.length} sellers with NULL plain_password`);

    const defaultPass = 'welcome123';
    const saltRounds = 10;
    const hash = await bcrypt.hash(defaultPass, saltRounds);

    for (const seller of sellers) {
      await pool.query(
        'UPDATE app_sellers SET password_hash = $1, plain_password = $2 WHERE seller_id = $3',
        [hash, defaultPass, seller.seller_id]
      );
      console.log(`Updated seller ${seller.seller_id} password to ${defaultPass}`);
    }
    console.log('Done!');
  } catch (err) {
    console.error(err);
  } finally {
    pool.end();
  }
}

run();
