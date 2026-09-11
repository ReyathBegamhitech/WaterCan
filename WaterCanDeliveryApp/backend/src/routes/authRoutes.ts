import { Router, Request, Response } from 'express';
import bcrypt from 'bcrypt';
import pool from '../config/db';

const router = Router();

router.post('/register', async (req: Request, res: Response): Promise<void> => {
  const { customerName, phone, whatsapp, email, address, password } = req.body;

  if (!customerName || !phone || !address || !password) {
    res.status(400).json({ success: false, message: 'Missing required fields' });
    return;
  }

  const client = await pool.connect();

  try {
    await client.query('BEGIN'); // Start transaction

    // 1. Check if phone number already exists
    const existingUser = await client.query('SELECT id FROM users WHERE phone_number = $1', [phone]);
    if (existingUser.rows.length > 0) {
      res.status(409).json({ success: false, message: 'Phone number is already registered' });
      await client.query('ROLLBACK');
      return;
    }

    // 2. Hash password
    const saltRounds = 10;
    const passwordHash = await bcrypt.hash(password, saltRounds);

    // 3. Insert into users table
    const userResult = await client.query(
      `INSERT INTO users (full_name, phone_number, email, password_hash) 
       VALUES ($1, $2, $3, $4) RETURNING id`,
      [customerName, phone, email || null, passwordHash]
    );
    const userId = userResult.rows[0].id;

    // 4. Insert into addresses table
    await client.query(
      `INSERT INTO addresses (user_id, address_line_1, city, pincode, is_default)
       VALUES ($1, $2, $3, $4, $5)`,
      [userId, address, 'Unknown', '000000', true] // Assuming City/Pincode aren't captured yet
    );

    await client.query('COMMIT'); // Complete transaction

    res.status(201).json({
      success: true,
      message: 'User registered successfully',
      userId: userId,
    });
  } catch (error) {
    await client.query('ROLLBACK'); // Abort transaction on error
    console.error('Registration error:', error);
    res.status(500).json({ success: false, message: 'Internal server error' });
  } finally {
    client.release();
  }
});

router.post('/login', async (req: Request, res: Response): Promise<void> => {
  const { phone, password } = req.body;

  if (!phone || !password) {
    res.status(400).json({ success: false, message: 'Missing phone or password' });
    return;
  }

  try {
    const userResult = await pool.query('SELECT id, full_name, password_hash FROM users WHERE phone_number = $1', [phone]);
    if (userResult.rows.length === 0) {
      res.status(401).json({ success: false, message: 'Invalid phone number or password' });
      return;
    }

    const user = userResult.rows[0];
    const isMatch = await bcrypt.compare(password, user.password_hash);
    
    if (!isMatch) {
      res.status(401).json({ success: false, message: 'Invalid phone number or password' });
      return;
    }

    const addressResult = await pool.query('SELECT address_line_1 FROM addresses WHERE user_id = $1 LIMIT 1', [user.id]);
    const address = addressResult.rows.length > 0 ? addressResult.rows[0].address_line_1 : '';

    res.status(200).json({
      success: true,
      message: 'Login successful',
      user: {
        id: user.id,
        fullName: user.full_name,
        phone: phone,
        address: address,
      }
    });
  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({ success: false, message: 'Internal server error' });
  }
});

router.put('/phone', async (req: Request, res: Response): Promise<void> => {
  const { oldPhone, newPhone } = req.body;

  if (!oldPhone || !newPhone) {
    res.status(400).json({ success: false, message: 'Missing phone numbers' });
    return;
  }

  try {
    const existing = await pool.query('SELECT id FROM users WHERE phone_number = $1', [newPhone]);
    if (existing.rows.length > 0) {
      res.status(409).json({ success: false, message: 'New phone number is already registered' });
      return;
    }

    const result = await pool.query(
      'UPDATE users SET phone_number = $1 WHERE phone_number = $2 RETURNING id',
      [newPhone, oldPhone]
    );

    if (result.rowCount === 0) {
      res.status(404).json({ success: false, message: 'User not found' });
      return;
    }

    res.status(200).json({ success: true, message: 'Phone number updated successfully' });
  } catch (error) {
    console.error('Update phone error:', error);
    res.status(500).json({ success: false, message: 'Internal server error' });
  }
});

export default router;
