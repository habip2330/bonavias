const express = require('express');
const cors = require('cors');
const { Pool } = require('pg');
const multer = require('multer');
const path = require('path');
const fs = require('fs');
const app = express();

// cPanel için port 80 kullanın (veya process.env.PORT)
const port = process.env.PORT || 80;

console.log('🚀 Bonavias API Server başlatılıyor...');
console.log('📡 Port:', port);
console.log('🌐 Environment:', process.env.NODE_ENV || 'production');

// Database bağlantısı - cPanel'de environment variable olarak ayarlayın
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

// Dosya yükleme için storage konfigürasyonu
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    const uploadDir = path.join(__dirname, 'public', 'uploads');
    
    if (!fs.existsSync(uploadDir)) {
      fs.mkdirSync(uploadDir, { recursive: true });
    }
    
    cb(null, uploadDir);
  },
  filename: function (req, file, cb) {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    const filename = uniqueSuffix + path.extname(file.originalname);
    cb(null, filename);
  }
});

const upload = multer({ 
  storage: storage,
  fileFilter: function (req, file, cb) {
    if (!file.originalname.match(/\.(jpg|jpeg|png|gif)$/)) {
      return cb(new Error('Sadece resim dosyaları yüklenebilir!'), false);
    }
    cb(null, true);
  }
});

// Middleware
app.use('/public', express.static(path.join(__dirname, 'public')));
app.use(cors());
app.use(express.json());

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

// Server başlatma
app.listen(port, () => {
  console.log(`🎉 Bonavias API Server ${port} portunda çalışıyor!`);
  console.log(`🌐 URL: http://localhost:${port}`);
  console.log(`📱 Flutter App API: https://habipbahceci.com/api`);
});

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log('🔄 SIGTERM alındı, server kapatılıyor...');
  pool.end();
  process.exit(0);
});

process.on('SIGINT', () => {
  console.log('🔄 SIGINT alındı, server kapatılıyor...');
  pool.end();
  process.exit(0);
});
