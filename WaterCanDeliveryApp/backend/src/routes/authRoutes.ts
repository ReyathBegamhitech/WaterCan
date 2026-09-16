import { Router, Request, Response } from 'express';
import bcrypt from 'bcrypt';
import dotenv from 'dotenv';
import pool from '../config/db';

dotenv.config();

const router = Router();

interface OtpEntry {
  otp: string;
  expiresAt: number;
  verified: boolean;
}

// In-memory OTP storage mapping 10-digit phone number -> OtpEntry
const otpStore = new Map<string, OtpEntry>();

async function dispatchRealSms(phone: string, otp: string): Promise<{ sent: boolean; gateway?: string; error?: string }> {
  dotenv.config(); // Ensure latest .env variables are loaded

  // 1. Check Fast2SMS (Free signup at https://www.fast2sms.com for India)
  const fast2smsKey = process.env.FAST2SMS_API_KEY?.trim();
  if (fast2smsKey) {
    try {
      console.log(`📡 [Fast2SMS] Dispatching real SMS to +91 ${phone}...`);
      const response = await fetch('https://www.fast2sms.com/dev/bulkV2', {
        method: 'POST',
        headers: {
          'authorization': fast2smsKey,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          route: 'otp',
          variables_values: otp,
          numbers: phone,
        }),
      });
      const data = await response.json() as any;
      console.log(`📲 [Fast2SMS Response]:`, data);

      if (data && data.return === true) {
        return { sent: true, gateway: 'Fast2SMS' };
      } else {
        const errorMsg = Array.isArray(data?.message) ? data.message.join(', ') : (data?.message || 'Fast2SMS returned false');
        return { sent: false, gateway: 'Fast2SMS', error: errorMsg };
      }
    } catch (e: any) {
      console.error(`❌ [Fast2SMS Dispatch Error]:`, e.message);
      return { sent: false, error: e.message };
    }
  }

  // 2. Check 2Factor (https://2factor.in)
  const twoFactorKey = process.env.TWOFACTOR_API_KEY?.trim();
  if (twoFactorKey) {
    try {
      console.log(`📡 [2Factor] Dispatching real SMS to +91 ${phone}...`);
      const response = await fetch(`https://2factor.in/API/V1/${twoFactorKey}/SMS/${phone}/${otp}/OTP1`);
      const data = await response.json() as any;
      console.log(`📲 [2Factor Response]:`, data);
      return { sent: true, gateway: '2Factor' };
    } catch (e: any) {
      console.error(`❌ [2Factor Dispatch Error]:`, e.message);
      return { sent: false, error: e.message };
    }
  }

  // 3. Check Twilio (https://twilio.com)
  const twilioSid = process.env.TWILIO_ACCOUNT_SID?.trim();
  const twilioAuth = process.env.TWILIO_AUTH_TOKEN?.trim();
  const twilioFrom = process.env.TWILIO_PHONE_NUMBER?.trim();
  if (twilioSid && twilioAuth && twilioFrom) {
    try {
      console.log(`📡 [Twilio] Dispatching real SMS to +91 ${phone}...`);
      const params = new URLSearchParams();
      params.append('To', `+91${phone}`);
      params.append('From', twilioFrom);
      params.append('Body', `Your WaterCan OTP is: ${otp}. Valid for 5 minutes.`);
      const auth = Buffer.from(`${twilioSid}:${twilioAuth}`).toString('base64');
      const response = await fetch(`https://api.twilio.com/2010-04-01/Accounts/${twilioSid}/Messages.json`, {
        method: 'POST',
        headers: {
          'Authorization': `Basic ${auth}`,
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: params.toString(),
      });
      const data = await response.json() as any;
      console.log(`📲 [Twilio Response]:`, data);
      return { sent: true, gateway: 'Twilio' };
    } catch (e: any) {
      console.error(`❌ [Twilio Dispatch Error]:`, e.message);
      return { sent: false, error: e.message };
    }
  }

  console.log(`ℹ️ [SMS Gateway] No active SMS API key in .env. To send real SMS to mobile phones, set FAST2SMS_API_KEY in backend/.env`);
  return { sent: false, gateway: 'none' };
}

// Endpoint to send real-time OTP to user's phone number
router.post('/send-otp', async (req: Request, res: Response): Promise<void> => {
  const { phone } = req.body;

  if (!phone || typeof phone !== 'string') {
    res.status(400).json({ success: false, message: 'Please provide a valid phone number' });
    return;
  }

  const cleanPhone = phone.trim().replace(/\D/g, '').slice(-10);
  if (cleanPhone.length !== 10) {
    res.status(400).json({ success: false, message: 'Please provide a valid 10-digit phone number' });
    return;
  }

  // Generate 4-digit OTP
  const otp = Math.floor(1000 + Math.random() * 9000).toString();
  // Valid for 5 minutes
  const expiresAt = Date.now() + 5 * 60 * 1000;

  otpStore.set(cleanPhone, {
    otp,
    expiresAt,
    verified: false,
  });

  console.log(`📱 [OTP Service] OTP for +91 ${cleanPhone} is: ${otp}`);

  // Attempt real telecom SMS dispatch
  const smsResult = await dispatchRealSms(cleanPhone, otp);

  if (!smsResult.sent) {
    otpStore.delete(cleanPhone);
    res.status(400).json({
      success: false,
      message: 'Failed to send real SMS: ' + (smsResult.error || 'No SMS gateway configured')
    });
    return;
  }

  res.status(200).json({
    success: true,
    message: `SMS sent successfully to +91 ${cleanPhone}!`,
    smsSent: true,
    gateway: smsResult.gateway
  });
});

// Endpoint to verify OTP entered by the user
router.post('/verify-otp', async (req: Request, res: Response): Promise<void> => {
  const { phone, otp } = req.body;

  if (!phone || !otp) {
    res.status(400).json({ success: false, message: 'Phone number and OTP code are required' });
    return;
  }

  const cleanPhone = phone.toString().trim().replace(/\D/g, '').slice(-10);
  const cleanOtp = otp.toString().trim();

  const entry = otpStore.get(cleanPhone);

  if (!entry) {
    res.status(400).json({ success: false, message: 'No OTP requested for this number. Tap "Send OTP" first.' });
    return;
  }

  if (Date.now() > entry.expiresAt) {
    otpStore.delete(cleanPhone);
    res.status(400).json({ success: false, message: 'OTP has expired. Please request a new one.' });
    return;
  }

  if (entry.otp !== cleanOtp) {
    res.status(400).json({ success: false, message: 'Invalid OTP code. Please check and try again.' });
    return;
  }

  // Mark phone as verified
  entry.verified = true;
  otpStore.set(cleanPhone, entry);

  console.log(`✅ [OTP Service] Verified phone: +91 ${cleanPhone}`);

  res.status(200).json({
    success: true,
    message: 'Phone number verified successfully',
  });
});

router.post('/register', async (req: Request, res: Response): Promise<void> => {
  const { customerName, phone, whatsapp, email, address, password } = req.body;

  if (!customerName || !phone || !address || !password) {
    res.status(400).json({ success: false, message: 'Missing required fields' });
    return;
  }

  const cleanPhone = phone.trim().replace(/\D/g, '').slice(-10);

  // Validate OTP verification before creating user
  const otpEntry = otpStore.get(cleanPhone);
  if (!otpEntry || !otpEntry.verified) {
    res.status(400).json({ success: false, message: 'Please verify your phone number via OTP before registering' });
    return;
  }

  const client = await pool.connect();

  try {
    await client.query('BEGIN'); // Start transaction

    // 1. Check if phone number already exists
    const existingUser = await client.query('SELECT id FROM users WHERE phone_number = $1', [cleanPhone]);
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
      [customerName, cleanPhone, email || null, passwordHash]
    );
    const userId = userResult.rows[0].id;

    // 4. Insert into addresses table
    await client.query(
      `INSERT INTO addresses (user_id, address_line_1, city, pincode, is_default)
       VALUES ($1, $2, $3, $4, $5)`,
      [userId, address, 'Unknown', '000000', true] // Assuming City/Pincode aren't captured yet
    );

    await client.query('COMMIT'); // Complete transaction

    // Clear verified OTP entry after successful registration
    otpStore.delete(cleanPhone);

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
