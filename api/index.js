const express = require('express');
const cors = require('cors');
const { Pool } = require('pg');

const app = express();

// Middleware
app.use(cors());
app.use(express.json());

// Database bağlantısı
const pool = new Pool({
  connectionString: process.env.DATABASE_URL || 'postgresql://username:password@localhost:5432/database_name',
  ssl: process.env.NODE_ENV === 'production' ? { rejectUnauthorized: false } : false,
});

// Health check endpoint
app.get('/api/health', (req, res) => {
  res.json({ 
    status: 'OK', 
    message: 'Bonavias API Server çalışıyor!',
    timestamp: new Date().toISOString(),
    environment: process.env.NODE_ENV || 'production'
  });
});

// Test endpoint
app.get('/api/test', (req, res) => {
  res.json({ message: 'Server is running!' });
});

// Slider endpoint
app.get('/api/sliders', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM sliders ORDER BY sort_order ASC, id DESC');
    res.json(result.rows);
  } catch (err) {
    console.error('❌ Sliders hatası:', err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Categories endpoint
app.get('/api/categories', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM categories ORDER BY sort_order ASC, id ASC');
    res.json(result.rows);
  } catch (err) {
    console.error('❌ Categories hatası:', err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Products endpoint
app.get('/api/products', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM products ORDER BY id DESC');
    res.json(result.rows);
  } catch (err) {
    console.error('❌ Products hatası:', err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Campaigns endpoint
app.get('/api/campaigns', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM campaigns ORDER BY id DESC');
    res.json(result.rows);
  } catch (err) {
    console.error('❌ Campaigns hatası:', err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Stories endpoint
app.get('/api/stories', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM stories ORDER BY id DESC');
    res.json(result.rows);
  } catch (err) {
    console.error('❌ Stories hatası:', err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Branches endpoint
app.get('/api/branches', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM branches ORDER BY id ASC');
    res.json(result.rows);
  } catch (err) {
    console.error('❌ Branches hatası:', err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Root endpoint
app.get('/', (req, res) => {
  res.json({ 
    message: 'Bonavias API Server',
    status: 'running',
    endpoints: ['/api/health', '/api/test', '/api/sliders', '/api/categories', '/api/products', '/api/campaigns', '/api/stories', '/api/branches']
  });
});

// Export for Vercel
module.exports = app;
