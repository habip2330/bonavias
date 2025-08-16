const express = require('express');
const { Pool } = require('pg');
const cors = require('cors');

const app = express();
const port = 3001;

app.use(cors());
app.use(express.json());

// Local PostgreSQL bağlantısı
const pool = new Pool({
  user: 'postgres',
  host: 'localhost',
  database: 'bonavias',
  password: 'Habip2330@1',
  port: 5432,
});

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'OK', message: 'PostgreSQL Proxy Server çalışıyor!' });
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

// Sliders endpoint
app.get('/api/sliders', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM sliders ORDER BY sort_order ASC, id DESC');
    res.json(result.rows);
  } catch (err) {
    console.error('❌ Sliders hatası:', err);
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

// Generic query endpoint (for testing)
app.post('/api/query', async (req, res) => {
  try {
    const { sql, params = [] } = req.body;
    if (!sql) {
      return res.status(400).json({ error: 'SQL query required' });
    }
    
    const result = await pool.query(sql, params);
    res.json({
      rows: result.rows,
      rowCount: result.rowCount,
      fields: result.fields
    });
  } catch (err) {
    console.error('❌ Query hatası:', err);
    res.status(500).json({ error: err.message });
  }
});

// Server başlat
app.listen(port, () => {
  console.log(`🚀 PostgreSQL Proxy Server ${port} portunda çalışıyor!`);
  console.log(`🌐 URL: http://localhost:${port}`);
  console.log(`📊 Endpoints:`);
  console.log(`  - /health - Sağlık kontrolü`);
  console.log(`  - /api/products - Ürünler`);
  console.log(`  - /api/categories - Kategoriler`);
  console.log(`  - /api/branches - Şubeler`);
  console.log(`  - /api/campaigns - Kampanyalar`);
  console.log(`  - /api/sliders - Slider'lar`);
  console.log(`  - /api/stories - Hikayeler`);
  console.log(`  - /api/query - Genel sorgu (POST)`);
  console.log(`\n🔗 Şimdi ngrok ile bu server'ı dış dünyaya açın:`);
  console.log(`   ngrok http ${port}`);
});

// Graceful shutdown
process.on('SIGINT', () => {
  console.log('\n🔄 Server kapatılıyor...');
  pool.end();
  process.exit(0);
});
