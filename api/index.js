const express = require('express');
const cors = require('cors');
const { Pool } = require('pg');

const app = express();

app.use(cors());
app.use(express.json());

// PostgreSQL bağlantısı
const pool = new Pool({
  connectionString: process.env.DATABASE_URL || 'postgresql://username:password@localhost:5432/database_name',
  ssl: process.env.NODE_ENV === 'production' ? { rejectUnauthorized: false } : false,
});

// Database bağlantı testi
pool.query('SELECT current_database()', (err, res) => {
  if (err) {
    console.error('❌ Database bağlantı hatası:', err);
  } else {
    console.log('✅ Database bağlandı:', res.rows[0]);
  }
});

// Test endpoint - bu kesin çalışacak
app.get('/api/test', (req, res) => {
  res.json({ 
    message: 'Server is running!',
    timestamp: new Date().toISOString(),
    status: 'OK'
  });
});

// Health endpoint
app.get('/api/health', (req, res) => {
  res.json({ 
    status: 'OK', 
    message: 'Bonavias API Server çalışıyor!',
    timestamp: new Date().toISOString()
  });
});

// Campaigns endpoint - PostgreSQL'den gerçek veri
app.get('/api/campaigns', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM campaigns ORDER BY id DESC');
    res.json(result.rows);
  } catch (err) {
    console.error('❌ Campaigns hatası:', err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Active campaigns endpoint - PostgreSQL'den gerçek veri
app.get('/api/campaigns/active', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM campaigns WHERE is_active = true ORDER BY id DESC');
    res.json(result.rows);
  } catch (err) {
    console.error('❌ Active campaigns hatası:', err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Products endpoint - PostgreSQL'den gerçek veri
app.get('/api/products', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM products ORDER BY id DESC');
    res.json(result.rows);
  } catch (err) {
    console.error('❌ Products hatası:', err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Categories endpoint - PostgreSQL'den gerçek veri
app.get('/api/categories', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM categories ORDER BY sort_order ASC, id ASC');
    res.json(result.rows);
  } catch (err) {
    console.error('❌ Categories hatası:', err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Sliders endpoint - PostgreSQL'den gerçek veri
app.get('/api/sliders', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM sliders ORDER BY sort_order ASC, id DESC');
    res.json(result.rows);
  } catch (err) {
    console.error('❌ Sliders hatası:', err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Stories endpoint - PostgreSQL'den gerçek veri
app.get('/api/stories', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM stories ORDER BY id DESC');
    res.json(result.rows);
  } catch (err) {
    console.error('❌ Stories hatası:', err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Branches endpoint - PostgreSQL'den gerçek veri
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
    endpoints: [
      '/api/health', 
      '/api/test', 
      '/api/campaigns', 
      '/api/campaigns/active',
      '/api/products', 
      '/api/categories', 
      '/api/sliders', 
      '/api/stories', 
      '/api/branches'
    ]
  });
});

// Export for Vercel
module.exports = app;
