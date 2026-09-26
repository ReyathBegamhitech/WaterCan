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
      console.log(`[2Factor] Dispatching Voice Call OTP to +91 ${phone}...`);
      const response = await fetch(`https://2factor.in/API/V1/${twoFactorKey}/VOICE/${phone}/${otp}`);
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
  const { phone, isRegistering } = req.body;

  if (!phone || typeof phone !== 'string') {
    res.status(400).json({ success: false, message: 'Please provide a valid phone number' });
    return;
  }

  const cleanPhone = phone.trim().replace(/\D/g, '').slice(-10);
  if (cleanPhone.length !== 10) {
    res.status(400).json({ success: false, message: 'Please provide a valid 10-digit phone number' });
    return;
  }

  if (isRegistering) {
    const userResult = await pool.query('SELECT * FROM users WHERE phone_number = $1', [cleanPhone]);
    if (userResult.rows.length > 0) {
      res.status(409).json({ success: false, message: 'Phone number is already registered. Please login.' });
      return;
    }
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

  console.log(`[Twilio OTP Service] OTP for +91 ${cleanPhone} is: ${otp}`);

  const result = await dispatchRealSms(cleanPhone, otp);
    
    if (!result.sent && result.gateway !== 'none') {
      otpStore.delete(cleanPhone);
      res.status(400).json({
        success: false,
        message: 'Failed to send SMS: ' + (result.error || 'Gateway configuration error')
      });
      return;
    }

    res.status(200).json({
      success: true,
      message: `OTP sent successfully to +91 ${cleanPhone}!`,
      smsSent: result.sent,
    });
});

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
  const { customerName, phone, whatsapp, email, doorNo, street, city, pincode, password, seller_id, fcmToken } = req.body;

  if (!customerName || !phone || !doorNo || !street || !city || !pincode || !password) {
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

    let assignedSellerId = null;
    let shopName = '';
    let shopAddress = '';

    if (seller_id) {
      const sellerResult = await client.query('SELECT organization_name, location FROM app_sellers WHERE seller_id = $1', [seller_id]);
      if (sellerResult.rows.length > 0) {
        assignedSellerId = seller_id;
        shopName = sellerResult.rows[0].organization_name;
        shopAddress = sellerResult.rows[0].location;
      }
    }

    // 3. Insert into users table
    const userResult = await client.query(
      `INSERT INTO users (full_name, phone_number, email, password_hash, assigned_seller_id, fcm_token) 
       VALUES ($1, $2, $3, $4, $5, $6) RETURNING id`,
      [customerName, cleanPhone, email || null, passwordHash, assignedSellerId, fcmToken || null]
    );
    const userId = userResult.rows[0].id;

    // 4. Insert into addresses table
    await client.query(
      `INSERT INTO addresses (user_id, door_no, street, city, pincode, is_default, latitude, longitude)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8)`,
      [userId, doorNo, street, city, pincode, true, req.body.latitude || null, req.body.longitude || null]
    );

    await client.query('COMMIT'); // Complete transaction

    // Clear verified OTP entry after successful registration
    otpStore.delete(cleanPhone);

    res.status(201).json({
      success: true,
      message: 'User registered successfully',
      userId: userId,
      assigned_seller_id: assignedSellerId,
      shop_name: shopName,
      shop_address: shopAddress
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
  const { phone, password, fcmToken } = req.body;

  if (!phone || !password) {
    res.status(400).json({ success: false, message: 'Missing phone or password' });
    return;
  }

  try {
    if (phone.startsWith('S-')) {
      // Seller Login Flow
      const sellerResult = await pool.query('SELECT seller_id, organization_name, password_hash, location, phone_number, plain_password FROM app_sellers WHERE seller_id = $1', [phone]);
      if (sellerResult.rows.length === 0) {
        res.status(401).json({ success: false, message: 'Invalid Seller ID or password' });
        return;
      }

      const seller = sellerResult.rows[0];
      const isMatch = await bcrypt.compare(password, seller.password_hash);
      
      if (!isMatch) {
        res.status(401).json({ success: false, message: 'Invalid Seller ID or password' });
        return;
      }

      // Update FCM token if provided
      if (fcmToken) {
        await pool.query('UPDATE app_sellers SET fcm_token = $1 WHERE seller_id = $2', [fcmToken, seller.seller_id]);
      }

      res.status(200).json({
        success: true,
        message: 'Seller Login successful',
        user: {
          isSeller: true,
          seller_id: seller.seller_id,
          fullName: seller.organization_name,
          phone: seller.phone_number || seller.seller_id,
          doorNo: seller.location,
        }
      });
      return;
    }

    // Check if it's a seller logging in by Phone Number
    const sellerByPhoneResult = await pool.query('SELECT seller_id, organization_name, password_hash, location, phone_number, plain_password FROM app_sellers WHERE phone_number = $1', [phone]);
    if (sellerByPhoneResult.rows.length > 0) {
      const seller = sellerByPhoneResult.rows[0];
      const isMatch = await bcrypt.compare(password, seller.password_hash);
      if (isMatch) {
        if (fcmToken) {
          await pool.query('UPDATE app_sellers SET fcm_token = $1 WHERE seller_id = $2', [fcmToken, seller.seller_id]);
        }
        res.status(200).json({
          success: true,
          message: 'Seller Login successful',
          user: {
            isSeller: true,
            seller_id: seller.seller_id,
            fullName: seller.organization_name,
            phone: seller.phone_number || seller.seller_id,
            doorNo: seller.location,
          }
        });
        return;
      }
    }

    // Check if it's a regular user logging in by Phone Number
    const userResult = await pool.query('SELECT id, full_name, password_hash, assigned_seller_id FROM users WHERE phone_number = $1', [phone]);
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

    const addressResult = await pool.query('SELECT door_no, street, city, pincode, latitude, longitude FROM addresses WHERE user_id = $1 LIMIT 1', [user.id]);
    const addressData = addressResult.rows.length > 0 ? addressResult.rows[0] : null;

    let shopName = '';
    let shopAddress = '';
    if (user.assigned_seller_id) {
      const shopResult = await pool.query('SELECT organization_name, location FROM app_sellers WHERE seller_id = $1', [user.assigned_seller_id]);
      if (shopResult.rows.length > 0) {
        shopName = shopResult.rows[0].organization_name;
        shopAddress = shopResult.rows[0].location;
      }
    }

    if (fcmToken) {
      await pool.query('UPDATE users SET fcm_token = $1 WHERE id = $2', [fcmToken, user.id]);
    }

    res.status(200).json({
      success: true,
      message: 'Login successful',
      user: {
        isSeller: false,
        id: user.id,
        fullName: user.full_name,
        phone: phone,
        doorNo: addressData?.door_no || '',
        street: addressData?.street || '',
        city: addressData?.city || '',
        pincode: addressData?.pincode || '',
        latitude: addressData?.latitude || null,
        longitude: addressData?.longitude || null,
        assigned_seller_id: user.assigned_seller_id,
        shop_name: shopName,
        shop_address: shopAddress
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

router.put('/address', async (req: Request, res: Response): Promise<void> => {
  const { phone, doorNo, street, city, pincode, latitude, longitude } = req.body;

  if (!phone || !doorNo || !street || !city || !pincode) {
    res.status(400).json({ success: false, message: 'Missing required fields' });
    return;
  }

  try {
    const userResult = await pool.query('SELECT id FROM users WHERE phone_number = $1', [phone]);
    if (userResult.rows.length === 0) {
      res.status(404).json({ success: false, message: 'User not found' });
      return;
    }

    const userId = userResult.rows[0].id;

    // Check if address exists
    const addressResult = await pool.query('SELECT id FROM addresses WHERE user_id = $1', [userId]);
    if (addressResult.rows.length === 0) {
      await pool.query(
        `INSERT INTO addresses (user_id, door_no, street, city, pincode, is_default, latitude, longitude) VALUES ($1, $2, $3, $4, $5, $6, $7, $8)`,
        [userId, doorNo, street, city, pincode, true, latitude || null, longitude || null]
      );
    } else {
      await pool.query(
        `UPDATE addresses SET door_no = $1, street = $2, city = $3, pincode = $4, latitude = $5, longitude = $6 WHERE user_id = $7`,
        [doorNo, street, city, pincode, latitude || null, longitude || null, userId]
      );
    }

    res.status(200).json({ success: true, message: 'Address updated successfully' });
  } catch (error) {
    console.error('Update address error:', error);
    res.status(500).json({ success: false, message: 'Internal server error' });
  }
});

// Get seller details for dynamic validation
router.get('/seller-details/:sellerId', async (req: Request, res: Response): Promise<void> => {
  const { sellerId } = req.params;
  if (!sellerId) {
    res.status(400).json({ success: false, message: 'Missing seller ID' });
    return;
  }
  
  try {
    const result = await pool.query('SELECT organization_name, location FROM app_sellers WHERE seller_id = $1', [sellerId]);
    if (result.rows.length === 0) {
      res.status(404).json({ success: false, message: 'Seller not found' });
      return;
    }
    
    res.status(200).json({
      success: true,
      shopName: result.rows[0].organization_name,
      location: result.rows[0].location
    });
  } catch (error) {
    console.error('Error fetching seller details:', error);
    res.status(500).json({ success: false, message: 'Internal server error' });
  }
});

export default router;

// Admin: Get all sellers
router.get('/admin/sellers', async (req: Request, res: Response): Promise<void> => {
  try {
    const query = `
      SELECT 
        s.seller_id, 
        s.organization_name, 
        s.location, 
        s.phone_number, 
        s.plain_password, 
        s.created_at,
        COUNT(o.id) as overall_orders,
        SUM(CASE WHEN o.status IN ('Placed', 'Accepted', 'Out for Delivery') THEN 1 ELSE 0 END) as orders_in_process,
        SUM(CASE WHEN EXTRACT(MONTH FROM o.created_at) = EXTRACT(MONTH FROM CURRENT_DATE) AND EXTRACT(YEAR FROM o.created_at) = EXTRACT(YEAR FROM CURRENT_DATE) THEN 1 ELSE 0 END) as monthly_orders,
        SUM(CASE WHEN o.status = 'Delivered' AND DATE(o.created_at) = CURRENT_DATE THEN 1 ELSE 0 END) as delivered_today,
        SUM(CASE WHEN o.status = 'Cancelled' THEN 1 ELSE 0 END) as cancelled_orders
      FROM app_sellers s
      LEFT JOIN app_orders o ON s.seller_id = o.seller_id
      GROUP BY s.seller_id, s.organization_name, s.location, s.phone_number, s.plain_password, s.created_at
      ORDER BY s.created_at DESC
    `;
    const result = await pool.query(query);
    res.status(200).json({ success: true, sellers: result.rows });
  } catch (error) {
    console.error('Fetch sellers error:', error);
    res.status(500).json({ success: false, message: 'Internal server error' });
  }
});

// Admin: Create a new seller
router.post('/admin/seller', async (req: Request, res: Response): Promise<void> => {
  const { sellerName, sellerId, contactNumber, address, password } = req.body;

  if (!sellerName || !sellerId || !contactNumber || !address || !password) {
    res.status(400).json({ success: false, message: 'Missing required fields' });
    return;
  }

  try {
    // Check if sellerId already exists
    const checkResult = await pool.query('SELECT seller_id FROM app_sellers WHERE seller_id = $1', [sellerId]);
    if (checkResult.rows.length > 0) {
      res.status(409).json({ success: false, message: 'Seller ID is already taken' });
      return;
    }

    const saltRounds = 10;
    const passwordHash = await bcrypt.hash(password, saltRounds);

    const result = await pool.query(
      `INSERT INTO app_sellers (seller_id, organization_name, location, phone_number, password_hash, plain_password)
       VALUES ($1, $2, $3, $4, $5, $6) RETURNING seller_id, organization_name, location, phone_number`,
      [sellerId, sellerName, address, contactNumber, passwordHash, password]
    );

    res.status(201).json({ success: true, message: 'Seller created successfully', seller: result.rows[0] });
  } catch (error) {
    console.error('Create seller error:', error);
    res.status(500).json({ success: false, message: 'Internal server error' });
  }
});

// Admin: Update a seller
router.put('/admin/seller/:id', async (req: Request, res: Response): Promise<void> => {
  const sellerId = req.params.id;
  const { sellerName, contactNumber, address, password } = req.body;

  if (!sellerName || !contactNumber || !address) {
    res.status(400).json({ success: false, message: 'Missing required fields' });
    return;
  }

  try {
    if (password && password.trim().length > 0) {
      const saltRounds = 10;
      const passwordHash = await bcrypt.hash(password, saltRounds);
      await pool.query(
        `UPDATE app_sellers 
         SET organization_name = $1, location = $2, phone_number = $3, password_hash = $4, plain_password = $5 
         WHERE seller_id = $6`,
        [sellerName, address, contactNumber, passwordHash, password, sellerId]
      );
    } else {
      await pool.query(
        `UPDATE app_sellers 
         SET organization_name = $1, location = $2, phone_number = $3 
         WHERE seller_id = $4`,
        [sellerName, address, contactNumber, sellerId]
      );
    }
    res.status(200).json({ success: true, message: 'Seller updated successfully' });
  } catch (error) {
    console.error('Update seller error:', error);
    res.status(500).json({ success: false, message: 'Internal server error' });
  }
});

// Admin: Delete a seller
router.delete('/admin/seller/:id', async (req: Request, res: Response): Promise<void> => {
  const sellerId = req.params.id;

  try {
    const result = await pool.query('DELETE FROM app_sellers WHERE seller_id = $1 RETURNING seller_id', [sellerId]);
    if (result.rowCount === 0) {
      res.status(404).json({ success: false, message: 'Seller not found' });
      return;
    }
    res.status(200).json({ success: true, message: 'Seller deleted successfully' });
  } catch (error) {
    console.error('Delete seller error:', error);
    res.status(500).json({ success: false, message: 'Internal server error' });
  }
});

// Admin: Get seller income by date
router.get('/admin/sellers/:id/income', async (req: Request, res: Response): Promise<void> => {
  const sellerId = req.params.id;
  const dateStr = req.query.date as string;

  if (!dateStr) {
    res.status(400).json({ success: false, message: 'Date is required' });
    return;
  }

  try {
    const result = await pool.query(
      `SELECT payment_method, SUM(total_price) as total 
       FROM app_orders 
       WHERE seller_id = $1 
         AND DATE(created_at AT TIME ZONE 'Asia/Kolkata') = $2 
         AND status = 'Delivered'
       GROUP BY payment_method`,
      [sellerId, dateStr]
    );

    let codIncome = 0;
    let upiIncome = 0;

    result.rows.forEach(row => {
      const pm = (row.payment_method || '').toLowerCase();
      const amount = parseFloat(row.total) || 0;
      if (pm.includes('cod') || pm.includes('cash')) {
        codIncome += amount;
      } else if (pm.includes('upi') || pm.includes('online')) {
        upiIncome += amount;
      }
    });

    res.status(200).json({ success: true, codIncome, upiIncome });
  } catch (error) {
    console.error('Fetch seller income error:', error);
    res.status(500).json({ success: false, message: 'Internal server error' });
  }
});

// Admin: Get distinct customers for a seller
router.get('/admin/sellers/:id/customers', async (req: Request, res: Response): Promise<void> => {
  const sellerId = req.params.id;

  try {
    const result = await pool.query(
      `SELECT DISTINCT buyer_name as name, buyer_phone as phone, delivery_address as address
       FROM app_orders 
       WHERE seller_id = $1 AND buyer_phone IS NOT NULL`,
      [sellerId]
    );

    res.status(200).json({ success: true, customers: result.rows });
  } catch (error) {
    console.error('Fetch seller customers error:', error);
    res.status(500).json({ success: false, message: 'Internal server error' });
  }
});

// User Deletion endpoint
router.delete('/delete', async (req: Request, res: Response): Promise<void> => {
  const { phone } = req.body;
  if (!phone) {
    res.status(400).json({ success: false, message: 'Phone number is required' });
    return;
  }
  const cleanPhone = phone.toString().trim().replace(/\D/g, '').slice(-10);

  try {
    const userResult = await pool.query('SELECT id FROM users WHERE phone_number = $1', [cleanPhone]);
    if (userResult.rows.length === 0) {
      res.status(404).json({ success: false, message: 'User not found' });
      return;
    }
    const userId = userResult.rows[0].id;

    await pool.query('BEGIN');
    
    // Delete user addresses
    await pool.query('DELETE FROM addresses WHERE user_id = $1', [userId]);
    
    // Delete orders linked to this user's phone number
    await pool.query('DELETE FROM app_orders WHERE user_phone = $1 OR buyer_phone = $2', [cleanPhone, cleanPhone]);
    
    // Delete user record
    await pool.query('DELETE FROM users WHERE id = $1', [userId]);
    
    await pool.query('COMMIT');
    
    console.log(`✅ [User Service] User with phone ${cleanPhone} completely deleted.`);
    res.status(200).json({ success: true, message: 'User deleted successfully from database' });
  } catch (error) {
    await pool.query('ROLLBACK');
    console.error('Delete user error:', error);
    res.status(500).json({ success: false, message: 'Internal server error while deleting user' });
  }
});


