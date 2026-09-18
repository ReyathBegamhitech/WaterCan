require('dotenv').config();
const { Pool } = require('pg');

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
});

async function runMigration() {
  try {
    await pool.query(`ALTER TABLE addresses RENAME COLUMN address_line_1 TO door_no`);
    console.log('Migration successful: Renamed address_line_1 to door_no.');
  } catch (err) {
    console.log('Migration skipped/failed for address_line_1:', err.message);
  }

  try {
    await pool.query(`ALTER TABLE addresses RENAME COLUMN address_line_2 TO street`);
    console.log('Migration successful: Renamed address_line_2 to street.');
  } catch (err) {
    console.log('Migration skipped/failed for address_line_2:', err.message);
  }

  pool.end();
}

runMigration();
