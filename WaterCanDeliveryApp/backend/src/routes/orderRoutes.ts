import { Router, Request, Response } from 'express';
import pool from '../config/db';

const router = Router();

// Place a new order
router.post('/', async (req, res) => {
  try {
    const { user_phone, buyer_name, buyer_phone, shop_name, quantity, price_per_can, total_price, time, delivery_address, order_details, payment_method, is_fast_delivery } = req.body;
    
    if (!user_phone || !shop_name || !quantity || !total_price) {
      return res.status(400).json({ success: false, message: 'Missing required order fields' });
    }

    const result = await pool.query(
      `INSERT INTO app_orders (user_phone, buyer_name, buyer_phone, shop_name, quantity, price_per_can, total_price, time, delivery_address, order_details, payment_method, is_fast_delivery) 
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12) RETURNING *`,
      [user_phone, buyer_name, buyer_phone, shop_name, quantity, price_per_can, total_price, time, delivery_address || '', order_details ? JSON.stringify(order_details) : null, payment_method || 'Cash on Delivery', is_fast_delivery || false]
    );

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
router.get('/seller', async (req, res) => {
  try {
    // For now, fetch all active orders for the seller.
    const result = await pool.query(
      'SELECT * FROM app_orders ORDER BY created_at DESC'
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
