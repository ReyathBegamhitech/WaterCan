import pool from './src/config/db';

async function runMigration() {
  try {
    await pool.query(`ALTER TABLE addresses RENAME COLUMN address_line_1 TO door_no`);
    console.log('Migration successful: Renamed address_line_1 to door_no.');
  } catch (err: any) {
    console.log('Migration skipped/failed for address_line_1:', err.message);
  }

  try {
    await pool.query(`ALTER TABLE addresses RENAME COLUMN address_line_2 TO street`);
    console.log('Migration successful: Renamed address_line_2 to street.');
  } catch (err: any) {
    console.log('Migration skipped/failed for address_line_2:', err.message);
  }

  pool.end();
}

runMigration();
