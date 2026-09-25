import { Router, Request, Response } from 'express';
import pool from '../config/db';
import * as admin from 'firebase-admin';

const router = Router();

// Place a new order
router.post('/', async (req, res) => {
  try {
    const { user_phone, buyer_name, buyer_phone, shop_name, quantity, price_per_can, total_price, time, delivery_address, latitude, longitude, order_details, payment_method, is_fast_delivery, seller_id } = req.body;
    
    if (!user_phone || !shop_name || !quantity || !total_price || !seller_id) {
      return res.status(400).json({ success: false, message: 'Missing required order fields' });
    }

    const result = await pool.query(
      `INSERT INTO app_orders (user_phone, buyer_name, buyer_phone, shop_name, quantity, price_per_can, total_price, time, delivery_address, latitude, longitude, order_details, payment_method, is_fast_delivery, seller_id) 
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15) RETURNING *`,
      [user_phone, buyer_name, buyer_phone, shop_name, quantity, price_per_can, total_price, time, delivery_address || '', latitude || null, longitude || null, order_details ? JSON.stringify(order_details) : null, payment_method || 'Cash on Delivery', is_fast_delivery || false, seller_id]
    );

    // Fetch the seller's FCM token
    try {
      const sellerResult = await pool.query('SELECT fcm_token FROM app_sellers WHERE seller_id = $1', [seller_id]);
      if (sellerResult.rows.length > 0) {
        const sellerFcmToken = sellerResult.rows[0].fcm_token;
        if (sellerFcmToken) {
          const message: admin.messaging.Message = {
            notification: {
              title: 'New Order Received! 🛒',
              body: `You received a new order from ${buyer_name || 'a customer'}.`
            },
            android: {
              priority: 'high' as const,
              notification: {
                channelId: 'order_updates_channel'
              }
            },
            data: {
              click_action: 'FLUTTER_NOTIFICATION_CLICK'
            },
            token: sellerFcmToken,
          };
          
          admin.messaging().send(message)
            .then(response => console.log('✅ Successfully sent push message:', response))
            .catch(error => console.error('❌ Error sending push message:', error));
        }
      }
    } catch (pushError) {
      console.error('Error fetching FCM token or sending push:', pushError);
    }

    res.status(201).json({ success: true, order: result.rows[0] });
  } catch (error) {
    console.error('Error creating order:', error);
    res.status(500).json({ success: false, message: 'Internal server error' });
  }
});

// Get orders for a specific user
router.get('/user/:phone', async (req, res) => {
  try {
    const { phone } = req.params;
    const result = await pool.query(
      'SELECT * FROM app_orders WHERE user_phone = $1 ORDER BY created_at DESC',
      [phone]
    );
    res.json({ success: true, orders: result.rows });
  } catch (error) {
    console.error('Error fetching user orders:', error);
    res.status(500).json({ success: false, message: 'Internal server error' });
  }
});

// Get all orders for the seller dashboard
router.get('/seller/:sellerId', async (req, res) => {
  try {
    const { sellerId } = req.params;
    const result = await pool.query(
      'SELECT * FROM app_orders WHERE seller_id = $1 ORDER BY created_at DESC',
      [sellerId]
    );
    res.json({ success: true, orders: result.rows });
  } catch (error) {
    console.error('Error fetching seller orders:', error);
    res.status(500).json({ success: false, message: 'Internal server error' });
  }
});

// Update order status (by seller)
router.put('/:id/status', async (req, res) => {
  try {
    const { id } = req.params;
    const { status } = req.body;

    if (!status) {
      return res.status(400).json({ success: false, message: 'Status is required' });
    }

    const result = await pool.query(
      'UPDATE app_orders SET status = $1 WHERE id = $2 RETURNING *',
      [status, id]
    );

    if (result.rowCount === 0) {
      return res.status(404).json({ success: false, message: 'Order not found' });
    }

    res.json({ success: true, order: result.rows[0] });
  } catch (error) {
    console.error('Error updating order status:', error);
    res.status(500).json({ success: false, message: 'Internal server error' });
  }
});

export default router;
