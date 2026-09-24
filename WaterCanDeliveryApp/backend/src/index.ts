import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import pool from './config/db';
import authRoutes from './routes/authRoutes';
import orderRoutes from './routes/orderRoutes';
import * as admin from 'firebase-admin';
import * as path from 'path';

// Initialize Firebase Admin SDK
try {
  // Check if FIREBASE_SERVICE_ACCOUNT is set in .env or Render dashboard
  if (process.env.FIREBASE_SERVICE_ACCOUNT) {
    const serviceAccount = JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT);
    admin.initializeApp({
      credential: admin.credential.cert(serviceAccount)
    });
    console.log('🔥 Firebase Admin initialized successfully');
  } else {
    console.warn('⚠️ FIREBASE_SERVICE_ACCOUNT environment variable is missing. Push notifications will not work.');
  }
} catch (error) {
  console.error('❌ Error initializing Firebase Admin:', error);
}

dotenv.config();

const app = express();
const port = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/orders', orderRoutes);

// Root route
app.get('/', (req, res) => {
  res.send('Welcome to the Water Can Delivery API! Check /api/test to verify your database connection.');
});

// Basic health check route
app.get('/api/test', async (req, res) => {
  try {
    const result = await pool.query('SELECT NOW()');
    res.json({
      success: true,
      message: 'Successfully connected to PostgreSQL!',
      timestamp: result.rows[0].now,
    });
  } catch (error) {
    console.error('Database connection error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to connect to database. Make sure you updated your .env file with the correct password!',
      error: error instanceof Error ? error.message : String(error),
    });
  }
});

app.listen(port, () => {
  console.log(`🚀 Server running on http://localhost:${port}`);
});
