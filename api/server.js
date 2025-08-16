const express = require('express');
const cors = require('cors');
const { Pool } = require('pg');
const multer = require('multer');
const path = require('path');
const fs = require('fs');
const app = express();
const port = 3001;

console.log('DB Connection:', process.env.DATABASE_URL || 'postgresql://postgres.wljqsddspfwobbuunqyn:bonavias2002@aws-0-eu-central-1.pooler.supabase.com:6543/postgres');

const pool = new Pool({
  connectionString: process.env.DATABASE_URL || 'postgresql://postgres.wljqsddspfwobbuunqyn:bonavias2002@aws-0-eu-central-1.pooler.supabase.com:6543/postgres',
  ssl: { rejectUnauthorized: false },
});

pool.query('SELECT current_database()', (err, res) => {
  if (err) {
    console.error('DB Test Error:', err);
  } else {
    console.log('Connected to DB:', res.rows[0]);
  }
});

// Dosya yükleme için storage konfigürasyonu
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    // Geçici olarak ana uploads klasörüne yükle
    const tempDir = path.join(__dirname, 'public', 'uploads');
    
    if (!fs.existsSync(tempDir)) {
      fs.mkdirSync(tempDir, { recursive: true });
    }
    
    cb(null, tempDir);
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
    // Sadece resim dosyalarını kabul et
    if (!file.originalname.match(/\.(jpg|jpeg|png|gif)$/)) {
      return cb(new Error('Sadece resim dosyaları yüklenebilir!'), false);
    }
    cb(null, true);
  }
});

// Statik dosya servis etme
app.use('/public', express.static(path.join(__dirname, 'public')));

// CORS middleware
app.use(cors());

// JSON middleware - sadece JSON istekleri için
app.use(express.json());

// Test endpoint'i
app.get('/api/test', (req, res) => {
  res.json({ message: 'Server is running!' });
});

// Slider endpoint'i
app.get('/api/sliders', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM sliders ORDER BY sort_order ASC, id DESC');
    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Slider tablosu kontrol endpoint'i
app.get('/api/check-sliders', async (req, res) => {
  try {
    // Önce tablo var mı kontrol et
    const tableCheck = await pool.query(`
      SELECT EXISTS (
        SELECT FROM information_schema.tables 
        WHERE table_name = 'sliders'
      );
    `);
    
    if (!tableCheck.rows[0].exists) {
      return res.json({ 
        error: 'sliders table does not exist',
        message: 'Please create the sliders table first'
      });
    }

    // Tablo varsa içeriğini getir
    const result = await pool.query('SELECT * FROM sliders');
    res.json({
      tableExists: true,
      count: result.rows.length,
      data: result.rows
    });
  } catch (err) {
    console.error('Slider check error:', err);
    res.status(500).json({ 
      error: 'Database error',
      details: err.message 
    });
  }
});

// Slider tablosunu oluştur endpoint'i
app.get('/api/create-sliders-table', async (req, res) => {
  try {
    await pool.query(`
      CREATE TABLE IF NOT EXISTS sliders (
        id SERIAL PRIMARY KEY,
        title VARCHAR(255) NOT NULL,
        description TEXT,
        image_url TEXT,
        link_url TEXT,
        is_active BOOLEAN DEFAULT true,
        sort_order INTEGER DEFAULT 0,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    `);
    
    // Test verisi ekle
    const existingCount = await pool.query('SELECT COUNT(*) FROM sliders');
    if (parseInt(existingCount.rows[0].count) === 0) {
      await pool.query(`
        INSERT INTO sliders (title, description, image_url, link_url, sort_order, is_active)
        VALUES 
          ('Hoş Geldiniz', 'Bonavias Cafe''ye hoş geldiniz', '/public/uploads/slider/welcome.jpg', '', 1, true),
          ('Özel Kahveler', 'En özel kahve çeşitlerimiz', '/public/uploads/slider/coffee.jpg', '', 2, true),
          ('Günün Fırsat', 'Bugünün özel fırsatları', '/public/uploads/slider/deals.jpg', '', 3, true);
      `);
    }

    res.json({ 
      success: true,
      message: 'Sliders table created and sample data added'
    });
  } catch (err) {
    console.error('Create sliders table error:', err);
    res.status(500).json({ 
      error: 'Database error',
      details: err.message 
    });
  }
});

// Kategoriler endpoint'leri
app.get('/api/categories', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM categories ORDER BY name');
    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Yeni kategori ekle
app.post('/api/categories', async (req, res) => {
  try {
    const { name, description, image_url, is_active } = req.body;
    
    const result = await pool.query(
      `INSERT INTO categories (name, description, image_url, is_active) 
       VALUES ($1, $2, $3, $4) RETURNING *`,
      [name, description, image_url, is_active !== false]
    );
    
    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error('Error creating category:', err);
    res.status(500).json({ error: 'Internal server error', details: err.message });
  }
});

// Kategori güncelle
app.put('/api/categories/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const { name, description, image_url, is_active } = req.body;
    
    const result = await pool.query(
      `UPDATE categories 
       SET name = $1, description = $2, image_url = $3, is_active = $4, updated_at = NOW()
       WHERE id = $5 RETURNING *`,
      [name, description, image_url, is_active !== false, id]
    );
    
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Category not found' });
    }
    
    res.json(result.rows[0]);
  } catch (err) {
    console.error('Error updating category:', err);
    res.status(500).json({ error: 'Internal server error', details: err.message });
  }
});

// Kategori sil
app.delete('/api/categories/:id', async (req, res) => {
  try {
    const { id } = req.params;
    
    // Önce bu kategoriye ait ürün var mı kontrol et
    const productCheck = await pool.query('SELECT COUNT(*) FROM products WHERE category_id = $1', [id]);
    
    if (parseInt(productCheck.rows[0].count) > 0) {
      return res.status(400).json({ 
        error: 'Bu kategoriye ait ürünler bulunmaktadır. Önce ürünleri silmelisiniz.' 
      });
    }
    
    const result = await pool.query('DELETE FROM categories WHERE id = $1 RETURNING *', [id]);
    
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Category not found' });
    }
    
    res.json({ message: 'Category deleted successfully' });
  } catch (err) {
    console.error('Error deleting category:', err);
    res.status(500).json({ error: 'Internal server error', details: err.message });
  }
});

// Ürünler endpoint'i
app.get('/api/products', async (req, res) => {
  try {
    let query = 'SELECT p.*, c.name as category_name FROM products p LEFT JOIN categories c ON p.category_id = c.id';
    const params = [];
    
    // Kategori ID'si ile filtreleme
    if (req.query.category_id) {
      query += ' WHERE p.category_id = $1';
      params.push(req.query.category_id);
    }
    
    query += ' ORDER BY p.name';
    
    const result = await pool.query(query, params);
    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Tek ürün getir
app.get('/api/products/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const result = await pool.query(
      'SELECT p.*, c.name as category_name FROM products p LEFT JOIN categories c ON p.category_id = c.id WHERE p.id = $1',
      [id]
    );
    
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Product not found' });
    }
    
    res.json(result.rows[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Yeni ürün ekle
app.post('/api/products', async (req, res) => {
  try {
    const { name, description, price, category_id, image_url, is_popular, is_available, ingredients } = req.body;
    
    const result = await pool.query(
      `INSERT INTO products (name, description, price, category_id, image_url, is_popular, is_available, ingredients) 
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8) RETURNING *`,
      [name, description, price, category_id, image_url, is_popular || false, is_available !== false, JSON.stringify(ingredients || [])]
    );
    
    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error('Error creating product:', err);
    res.status(500).json({ error: 'Internal server error', details: err.message });
  }
});

// Ürün güncelle
app.put('/api/products/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const { name, description, price, category_id, image_url, is_popular, is_available, ingredients } = req.body;
    
    const result = await pool.query(
      `UPDATE products 
       SET name = $1, description = $2, price = $3, category_id = $4, image_url = $5, 
           is_popular = $6, is_available = $7, ingredients = $8, updated_at = NOW()
       WHERE id = $9 RETURNING *`,
      [name, description, price, category_id, image_url, is_popular || false, is_available !== false, JSON.stringify(ingredients || []), id]
    );
    
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Product not found' });
    }
    
    res.json(result.rows[0]);
  } catch (err) {
    console.error('Error updating product:', err);
    res.status(500).json({ error: 'Internal server error', details: err.message });
  }
});

// Ürün sil
app.delete('/api/products/:id', async (req, res) => {
  try {
    const { id } = req.params;
    
    const result = await pool.query('DELETE FROM products WHERE id = $1 RETURNING *', [id]);
    
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Product not found' });
    }
    
    res.json({ message: 'Product deleted successfully' });
  } catch (err) {
    console.error('Error deleting product:', err);
    res.status(500).json({ error: 'Internal server error', details: err.message });
  }
});

// Test endpoint for debugging upload
app.post('/api/test-upload', (req, res) => {
  console.log('=== TEST UPLOAD ===');
  console.log('Raw body:', req.body);
  console.log('Content-Type:', req.headers['content-type']);
  
  upload.single('image')(req, res, function (err) {
    console.log('After multer - body:', req.body);
    console.log('After multer - file:', req.file ? 'File received' : 'No file');
    
    res.json({
      body: req.body,
      hasFile: !!req.file,
      folder: req.body.folder
    });
  });
});

// Dosya yükleme endpoint'i
app.post('/api/upload', upload.single('image'), (req, res) => {
  console.log('=== UPLOAD REQUEST START ===');
  
  try {
    if (!req.file) {
      console.error('No file received in request');
      return res.status(400).json({ error: 'Dosya yüklenemedi' });
    }

    const folder = req.body.folder || 'general';
    console.log('Target folder:', folder);
    
    // Hedef klasörü oluştur
    const targetDir = path.join(__dirname, 'public', 'uploads', folder);
    if (!fs.existsSync(targetDir)) {
      fs.mkdirSync(targetDir, { recursive: true });
      console.log('Created target directory:', targetDir);
    }
    
    // Dosyayı hedef klasöre taşı
    const oldPath = req.file.path;
    const newPath = path.join(targetDir, req.file.filename);
    
    fs.renameSync(oldPath, newPath);
    console.log('File moved from', oldPath, 'to', newPath);
    
    const fileUrl = `/public/uploads/${folder}/${req.file.filename}`;
    
    console.log('File uploaded successfully!');
    console.log('- Folder:', folder);
    console.log('- Filename:', req.file.filename);
    console.log('- Final path:', newPath);
    console.log('- URL:', fileUrl);
    console.log('=== UPLOAD REQUEST END ===');
    
    res.json({ 
      success: true,
      url: fileUrl
    });
  } catch (error) {
    console.error('Upload error:', error);
    res.status(500).json({ 
      error: 'Dosya yükleme hatası',
      details: error.message 
    });
  }
});

// Multer error handling middleware
app.use((err, req, res, next) => {
  if (err instanceof multer.MulterError) {
    console.error('Multer error:', err);
    return res.status(400).json({ error: 'Dosya yükleme hatası', details: err.message });
  }
  next(err);
});

// Kampanyalar endpoint'i
app.get('/api/campaigns', async (req, res) => {
  try {
    console.log('📡 Campaigns endpoint called');
    const result = await pool.query('SELECT * FROM campaigns ORDER BY created_at DESC');
    console.log(`📊 Found ${result.rows.length} campaigns`);
    
    // Her kampanya için detayları logla
    result.rows.forEach((campaign, index) => {
      console.log(`📋 Campaign ${index + 1}: ID=${campaign.id}, Title=${campaign.title}, Active=${campaign.is_active}`);
    });
    
    res.json(result.rows);
  } catch (err) {
    console.error('❌ Error fetching campaigns:', err);
    res.status(500).json({ error: 'Internal server error', details: err.message });
  }
});

// Aktif kampanyalar endpoint'i
app.get('/api/campaigns/active', async (req, res) => {
  try {
    console.log('📡 Active campaigns endpoint called');
    const result = await pool.query(`
      SELECT * FROM campaigns 
      WHERE is_active = true 
      AND (start_date IS NULL OR start_date <= NOW())
      AND (end_date IS NULL OR end_date >= NOW())
      ORDER BY created_at DESC
    `);
    console.log(`📊 Found ${result.rows.length} active campaigns`);
    
    result.rows.forEach((campaign, index) => {
      console.log(`✅ Active Campaign ${index + 1}: ID=${campaign.id}, Title=${campaign.title}`);
    });
    
    res.json(result.rows);
  } catch (err) {
    console.error('❌ Error fetching active campaigns:', err);
    res.status(500).json({ error: 'Internal server error', details: err.message });
  }
});

// Tek kampanya endpoint'i
app.get('/api/campaigns/:id', async (req, res) => {
  try {
    const { id } = req.params;
    console.log(`📡 Single campaign endpoint called for ID: ${id}`);
    
    const result = await pool.query('SELECT * FROM campaigns WHERE id = $1', [id]);
    
    if (result.rows.length === 0) {
      console.log(`❌ Campaign not found for ID: ${id}`);
      return res.status(404).json({ error: 'Campaign not found' });
    }
    
    console.log(`✅ Found campaign: ${result.rows[0].title}`);
    res.json(result.rows[0]);
  } catch (err) {
    console.error('❌ Error fetching campaign:', err);
    res.status(500).json({ error: 'Internal server error', details: err.message });
  }
});

// Yeni kampanya ekle
app.post('/api/campaigns', async (req, res) => {
  try {
    console.log('📡 Create campaign endpoint called');
    console.log('📋 Request body:', req.body);
    
    const { title, description, start_date, end_date, is_active, image_url } = req.body;
    
    const result = await pool.query(
      `INSERT INTO campaigns (title, description, start_date, end_date, is_active, image_url) 
       VALUES ($1, $2, $3, $4, $5, $6) RETURNING *`,
      [title, description, start_date, end_date, is_active !== false, image_url]
    );
    
    console.log(`✅ Campaign created successfully: ${result.rows[0].title}`);
    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error('❌ Error creating campaign:', err);
    res.status(500).json({ error: 'Internal server error', details: err.message });
  }
});

// Kampanya güncelle
app.put('/api/campaigns/:id', async (req, res) => {
  try {
    const { id } = req.params;
    console.log(`📡 Update campaign endpoint called for ID: ${id}`);
    console.log('📋 Request body:', req.body);
    
    const { title, description, start_date, end_date, is_active, image_url } = req.body;
    
    const result = await pool.query(
      `UPDATE campaigns 
       SET title = $1, description = $2, start_date = $3, end_date = $4, 
           is_active = $5, image_url = $6, updated_at = NOW()
       WHERE id = $7 RETURNING *`,
      [title, description, start_date, end_date, is_active !== false, image_url, id]
    );
    
    if (result.rows.length === 0) {
      console.log(`❌ Campaign not found for ID: ${id}`);
      return res.status(404).json({ error: 'Campaign not found' });
    }
    
    console.log(`✅ Campaign updated successfully: ${result.rows[0].title}`);
    res.json(result.rows[0]);
  } catch (err) {
    console.error('❌ Error updating campaign:', err);
    res.status(500).json({ error: 'Internal server error', details: err.message });
  }
});

// Kampanya sil
app.delete('/api/campaigns/:id', async (req, res) => {
  try {
    const { id } = req.params;
    console.log(`📡 Delete campaign endpoint called for ID: ${id}`);
    
    const result = await pool.query('DELETE FROM campaigns WHERE id = $1 RETURNING *', [id]);
    
    if (result.rows.length === 0) {
      console.log(`❌ Campaign not found for ID: ${id}`);
      return res.status(404).json({ error: 'Campaign not found' });
    }
    
    console.log(`✅ Campaign deleted successfully: ${result.rows[0].title}`);
    res.json({ message: 'Campaign deleted successfully' });
  } catch (err) {
    console.error('❌ Error deleting campaign:', err);
    res.status(500).json({ error: 'Internal server error', details: err.message });
  }
});

// Kampanya tablosunu güncelle endpoint'i - eksik sütunları ekle
app.get('/api/update-campaigns-table', async (req, res) => {
  try {
    // Önce tablo var mı kontrol et
    const tableCheck = await pool.query(`
      SELECT EXISTS (
        SELECT FROM information_schema.tables 
        WHERE table_name = 'campaigns'
      );
    `);
    
    if (!tableCheck.rows[0].exists) {
      // Tablo yoksa oluştur
      await pool.query(`
        CREATE TABLE campaigns (
          id SERIAL PRIMARY KEY,
          title VARCHAR(255) NOT NULL,
          description TEXT,
          image_url VARCHAR(255),
          start_date TIMESTAMP WITH TIME ZONE NOT NULL,
          end_date TIMESTAMP WITH TIME ZONE NOT NULL,
          is_active BOOLEAN DEFAULT true,
          created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
          updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
        );
      `);
      
      // Trigger ekle
      await pool.query(`
        CREATE TRIGGER update_campaigns_updated_at
          BEFORE UPDATE ON campaigns
          FOR EACH ROW
          EXECUTE FUNCTION update_updated_at_column();
      `);
      
      // Test verisi ekle
      await pool.query(`
        INSERT INTO campaigns (title, description, start_date, end_date, is_active, image_url)
        VALUES 
          ('Hoş Geldin İndirimi', 'Yeni müşteriler için özel kampanya', NOW(), NOW() + INTERVAL '30 days', true, '/public/uploads/campaigns/welcome.jpg'),
          ('Kahve Festivali', 'Tüm kahvelerde özel fiyatlar', NOW(), NOW() + INTERVAL '15 days', true, '/public/uploads/campaigns/coffee-festival.jpg'),
          ('Hafta Sonu Fırsatı', 'Hafta sonu özel menü', NOW(), NOW() + INTERVAL '7 days', true, '/public/uploads/campaigns/weekend.jpg');
      `);
    } else {
      // Tablo varsa eksik sütunları kontrol et ve ekle
      

      
      // is_active sütunu var mı kontrol et
      const isActiveColumnCheck = await pool.query(`
        SELECT EXISTS (
          SELECT FROM information_schema.columns 
          WHERE table_name = 'campaigns' AND column_name = 'is_active'
        );
      `);
      
      if (!isActiveColumnCheck.rows[0].exists) {
        // Önce active sütunu varsa is_active olarak rename et
        const activeColumnCheck = await pool.query(`
          SELECT EXISTS (
            SELECT FROM information_schema.columns 
            WHERE table_name = 'campaigns' AND column_name = 'active'
          );
        `);
        
        if (activeColumnCheck.rows[0].exists) {
          await pool.query('ALTER TABLE campaigns RENAME COLUMN active TO is_active;');
          console.log('✅ active column renamed to is_active in campaigns table');
        } else {
          await pool.query('ALTER TABLE campaigns ADD COLUMN is_active BOOLEAN DEFAULT true;');
          console.log('✅ is_active column added to campaigns table');
        }
      }
    }

    res.json({ 
      success: true,
      message: 'Campaigns table updated successfully'
    });
  } catch (err) {
    console.error('Update campaigns table error:', err);
    res.status(500).json({ 
      error: 'Database error',
      details: err.message 
    });
  }
});

// Notifications tablosunu oluştur endpoint'i
app.get('/api/create-notifications-table', async (req, res) => {
  try {
    await pool.query(`
      DROP TABLE IF EXISTS notifications;
      CREATE TABLE notifications (
        id SERIAL PRIMARY KEY,
        user_id VARCHAR(255) NOT NULL,
        title VARCHAR(255) NOT NULL,
        message TEXT NOT NULL,
        type VARCHAR(50) DEFAULT 'info',
        target_audience VARCHAR(50) DEFAULT 'all',
        scheduled_for TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        expires_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP + INTERVAL '30 days'),
        is_active BOOLEAN DEFAULT true,
        is_read BOOLEAN DEFAULT false,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    `);
    
    // Test verisi ekle
    await pool.query(`
      INSERT INTO notifications (user_id, title, message, type, target_audience, is_active)
      VALUES 
        ('test_user', 'Hoş Geldiniz', 'Bonavias Cafe''ye hoş geldiniz!', 'info', 'all', true),
        ('test_user', 'Yeni Menü', 'Yeni menümüz yayında! Hemen göz atın.', 'info', 'customers', true),
        ('test_user', 'Özel İndirim', 'Bu hafta tüm kahvelerde %20 indirim!', 'success', 'all', true);
    `);
    
    res.json({ 
      success: true,
      message: 'Notifications table created and sample data added'
    });
  } catch (err) {
    console.error('Create notifications table error:', err);
    res.status(500).json({ 
      error: 'Database error',
      details: err.message 
    });
  }
});

// Admin Notifications API Endpoints
app.get('/api/notifications', async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT 
        id, 
        user_id,
        title, 
        message, 
        COALESCE(type, 'info') as type,
        COALESCE(target_audience, 'all') as target_audience,
        COALESCE(scheduled_for, NOW()) as scheduled_for,
        COALESCE(expires_at, NOW() + INTERVAL '30 days') as expires_at,
        COALESCE(is_active, true) as is_active,
        COALESCE(is_read, false) as is_read,
        created_at,
        updated_at
      FROM notifications 
      ORDER BY created_at DESC
    `);
    res.json(result.rows);
  } catch (err) {
    console.error('Error fetching notifications:', err);
    res.status(500).json({ error: 'Internal server error', details: err.message });
  }
});

// Mobile app notifications endpoint
app.get('/api/notifications/:userId', async (req, res) => {
  try {
    const { userId } = req.params;
    const result = await pool.query(`
      SELECT 
        id, 
        user_id,
        title, 
        message, 
        COALESCE(type, 'info') as type,
        COALESCE(target_audience, 'all') as target_audience,
        COALESCE(scheduled_for, NOW()) as scheduled_for,
        COALESCE(expires_at, NOW() + INTERVAL '30 days') as expires_at,
        COALESCE(is_active, true) as is_active,
        COALESCE(is_read, false) as is_read,
        created_at,
        updated_at
      FROM notifications 
      WHERE user_id = $1 OR target_audience = 'all'
      ORDER BY created_at DESC
    `, [userId]);
    res.json(result.rows);
  } catch (err) {
    console.error('Error fetching notifications:', err);
    res.status(500).json({ error: 'Internal server error', details: err.message });
  }
});

app.post('/api/notifications', async (req, res) => {
  try {
    const { 
      user_id,
      title, 
      message, 
      type = 'info',
      target_audience = 'all',
      scheduled_for = new Date(),
      expires_at = new Date(Date.now() + 30 * 24 * 60 * 60 * 1000),
      is_active = true
    } = req.body;

    const result = await pool.query(
      `INSERT INTO notifications 
        (user_id, title, message, type, target_audience, scheduled_for, expires_at, is_active) 
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8) 
       RETURNING *`,
      [user_id, title, message, type, target_audience, scheduled_for, expires_at, is_active]
    );
    
    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error('Error creating notification:', err);
    res.status(500).json({ error: 'Internal server error', details: err.message });
  }
});

app.put('/api/notifications/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const { 
      user_id,
      title, 
      message, 
      type,
      target_audience,
      scheduled_for,
      expires_at,
      is_active
    } = req.body;

    const result = await pool.query(
      `UPDATE notifications 
       SET user_id = $1,
           title = $2, 
           message = $3, 
           type = $4,
           target_audience = $5,
           scheduled_for = $6,
           expires_at = $7,
           is_active = $8,
           updated_at = NOW()
       WHERE id = $9 
       RETURNING *`,
      [user_id, title, message, type, target_audience, scheduled_for, expires_at, is_active, id]
    );
    
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Notification not found' });
    }
    
    res.json(result.rows[0]);
  } catch (err) {
    console.error('Error updating notification:', err);
    res.status(500).json({ error: 'Internal server error', details: err.message });
  }
});

app.delete('/api/notifications/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const result = await pool.query(
      'DELETE FROM notifications WHERE id = $1 RETURNING *',
      [id]
    );
    
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Notification not found' });
    }
    
    res.json(result.rows[0]);
  } catch (err) {
    console.error('Error deleting notification:', err);
    res.status(500).json({ error: 'Internal server error', details: err.message });
  }
});

// Bildirimi okundu olarak işaretle
app.put('/api/notifications/:id/read', async (req, res) => {
  try {
    const { id } = req.params;
    const result = await pool.query(
      `UPDATE notifications 
       SET is_read = true, updated_at = NOW()
       WHERE id = $1 
       RETURNING *`,
      [id]
    );
    
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Notification not found' });
    }
    
    res.json(result.rows[0]);
  } catch (err) {
    console.error('Error marking notification as read:', err);
    res.status(500).json({ error: 'Internal server error', details: err.message });
  }
});

// Tüm bildirimleri okundu olarak işaretle
app.put('/api/notifications/:userId/read-all', async (req, res) => {
  try {
    const { userId } = req.params;
    const result = await pool.query(
      `UPDATE notifications 
       SET is_read = true, updated_at = NOW()
       WHERE (user_id = $1 OR target_audience = 'all') AND is_read = false
       RETURNING *`,
      [userId]
    );
    
    res.json(result.rows);
  } catch (err) {
    console.error('Error marking all notifications as read:', err);
    res.status(500).json({ error: 'Internal server error', details: err.message });
  }
});

// SSS (FAQ) endpoint'i
app.get('/api/faqs', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM faqs WHERE is_active = true ORDER BY id DESC');
    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Tüm şubeleri getir
app.get('/api/branches', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM branches ORDER BY id');
    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Yeni şube ekle
app.post('/api/branches', async (req, res) => {
  const { name, address, phone, email, latitude, longitude, working_hours, is_active, location } = req.body;
  try {
    console.log('📝 Adding new branch:', { name, address, phone, email, latitude, longitude, working_hours, is_active, location });
    
    // working_hours'u JSON olarak işle
    let workingHoursJson;
    if (typeof working_hours === 'string') {
      try {
        workingHoursJson = JSON.parse(working_hours);
      } catch {
        workingHoursJson = working_hours; // String olarak bırak
      }
    } else {
      workingHoursJson = working_hours;
    }
    
    const safeValues = [
      name || '',
      address || '',
      phone || '',
      email || null,
      parseFloat(latitude) || 0,
      parseFloat(longitude) || 0,
      workingHoursJson,
      Boolean(is_active !== false),
      location || address || ''
    ];
    
    console.log('🔧 Values for insert:', safeValues);
    
    const result = await pool.query(
      'INSERT INTO branches (name, address, phone, email, latitude, longitude, working_hours, is_active, location) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9) RETURNING *',
      safeValues
    );
    
    console.log('✅ Branch added:', result.rows[0]);
    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error('❌ Error adding branch:', err);
    res.status(500).json({ error: 'Internal server error', details: err.message });
  }
});

// Şube güncelle
app.put('/api/branches/:id', async (req, res) => {
  const { id } = req.params;
  const { name, address, phone, email, latitude, longitude, working_hours, is_active, location } = req.body;
  try {
    console.log('📝 Updating branch:', id, { name, address, phone, email, latitude, longitude, working_hours, is_active, location });
    
    // working_hours'u JSON olarak işle
    let workingHoursJson;
    if (typeof working_hours === 'string') {
      try {
        workingHoursJson = JSON.parse(working_hours);
      } catch {
        workingHoursJson = working_hours; // String olarak bırak
      }
    } else {
      workingHoursJson = working_hours;
    }
    
    const lat = parseFloat(latitude);
    const lng = parseFloat(longitude);
    
    console.log('🔍 Converted values:', { lat, lng, workingHoursJson });
    
    // Güvenli değer dönüştürme
    const safeValues = [
      name || '',
      address || '',
      phone || '',
      email || null,
      isNaN(lat) ? 0 : lat,
      isNaN(lng) ? 0 : lng,
      workingHoursJson,
      Boolean(is_active !== false),
      location || address || '',
      id
    ];
    
    console.log('🔧 Final safe values:', safeValues);
    
    const result = await pool.query(
      'UPDATE branches SET name=$1, address=$2, phone=$3, email=$4, latitude=$5, longitude=$6, working_hours=$7, is_active=$8, location=$9, updated_at=NOW() WHERE id=$10 RETURNING *',
      safeValues
    );
    
    console.log('✅ Branch updated:', result.rows[0]);
    res.json(result.rows[0]);
  } catch (err) {
    console.error('❌ Error updating branch:', err);
    res.status(500).json({ error: 'Internal server error', details: err.message });
  }
});

// Şube sil
app.delete('/api/branches/:id', async (req, res) => {
  const { id } = req.params;
  try {
    await pool.query('DELETE FROM branches WHERE id=$1', [id]);
    res.json({ message: 'Branch deleted' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Branches tablosunu kontrol et
app.get('/api/check-branches-table', async (req, res) => {
  try {
    console.log('🔍 Checking branches table structure...');
    
    // Mevcut kolon yapısını kontrol et
    const existingColumns = await pool.query(`
      SELECT column_name, data_type, is_nullable, column_default
      FROM information_schema.columns 
      WHERE table_name = 'branches'
      ORDER BY ordinal_position;
    `);
    
    console.log('📋 Existing columns:', existingColumns.rows);
    
    // Mevcut veriyi göster
    const sampleData = await pool.query('SELECT * FROM branches LIMIT 3');
    console.log('📝 Sample data:', sampleData.rows);
    
    res.json({ 
      success: true,
      columns: existingColumns.rows,
      sampleData: sampleData.rows
    });
  } catch (err) {
    console.error('❌ Check branches table error:', err);
    res.status(500).json({ 
      error: 'Database error',
      details: err.message 
    });
  }
});

// Working Hours Migration endpoint  
app.get('/api/migrate-working-hours', async (req, res) => {
  try {
    console.log('🔄 Starting working hours migration...');
    
    // 1. Add location column if not exists
    await pool.query(`
      ALTER TABLE branches 
      ADD COLUMN IF NOT EXISTS location TEXT;
    `);
    console.log('✅ Added location column');
    
    // 2. Add working_hours JSONB column if not exists
    await pool.query(`
      ALTER TABLE branches 
      ADD COLUMN IF NOT EXISTS working_hours JSONB;
    `);
    console.log('✅ Added working_hours JSONB column');
    
    // 3. Set default working hours for existing branches
    await pool.query(`
      UPDATE branches 
      SET working_hours = '{
        "monday": {"day": "Pazartesi", "isOpen": true, "openTime": "09:00", "closeTime": "22:00"},
        "tuesday": {"day": "Salı", "isOpen": true, "openTime": "09:00", "closeTime": "22:00"},
        "wednesday": {"day": "Çarşamba", "isOpen": true, "openTime": "09:00", "closeTime": "22:00"},
        "thursday": {"day": "Perşembe", "isOpen": true, "openTime": "09:00", "closeTime": "22:00"},
        "friday": {"day": "Cuma", "isOpen": true, "openTime": "09:00", "closeTime": "22:00"},
        "saturday": {"day": "Cumartesi", "isOpen": true, "openTime": "09:00", "closeTime": "22:00"},
        "sunday": {"day": "Pazar", "isOpen": true, "openTime": "09:00", "closeTime": "22:00"}
      }'::JSONB
      WHERE working_hours IS NULL;
    `);
    console.log('✅ Set default working hours for existing branches');
    
    // 4. Make opening_hours nullable (optional)
    await pool.query(`
      ALTER TABLE branches 
      ALTER COLUMN opening_hours DROP NOT NULL;
    `);
    console.log('✅ Made opening_hours nullable');
    
    res.json({ 
      success: true, 
      message: 'Working hours migration completed successfully!' 
    });
    
  } catch (error) {
    console.error('❌ Migration error:', error);
    res.status(500).json({ 
      success: false, 
      error: 'Migration failed', 
      details: error.message 
    });
  }
});

// Branches tablosunu düzelt (JSON → TEXT)
app.get('/api/force-fix-branches', async (req, res) => {
  try {
    console.log('🔧 Force fixing branches table...');
    
    // working_hours kolonunu JSON'dan TEXT'e zorla çevir
    try {
      await pool.query(`ALTER TABLE branches ALTER COLUMN working_hours TYPE TEXT USING working_hours::text;`);
      console.log('✅ working_hours converted from JSON to TEXT');
    } catch (e) {
      console.log('⚠️ working_hours conversion failed:', e.message);
    }
    
    // location kolonunu da TEXT'e çevir
    try {
      await pool.query(`ALTER TABLE branches ALTER COLUMN location TYPE TEXT USING location::text;`);
      console.log('✅ location converted to TEXT');
    } catch (e) {
      console.log('⚠️ location conversion failed:', e.message);
    }
    
    // latitude/longitude'u DECIMAL'e çevir
    try {
      await pool.query(`ALTER TABLE branches ALTER COLUMN latitude TYPE DECIMAL(10, 8) USING latitude::decimal;`);
      await pool.query(`ALTER TABLE branches ALTER COLUMN longitude TYPE DECIMAL(11, 8) USING longitude::decimal;`);
      console.log('✅ lat/lng converted to DECIMAL');
    } catch (e) {
      console.log('⚠️ lat/lng conversion failed:', e.message);
    }
    
    // Final column check
    const finalColumns = await pool.query(`
      SELECT column_name, data_type 
      FROM information_schema.columns 
      WHERE table_name = 'branches'
      ORDER BY ordinal_position;
    `);
    
    console.log('📋 Final column types:', finalColumns.rows);
    
    res.json({ 
      success: true,
      message: 'All column types fixed successfully',
      columns: finalColumns.rows
    });
  } catch (err) {
    console.error('❌ Force fix error:', err);
    res.status(500).json({ 
      error: 'Database error',
      details: err.message 
    });
  }
});

// Products tablosu kontrol endpoint'i
app.get('/api/check-products', async (req, res) => {
  try {
    // Önce tablo var mı kontrol et
    const tableCheck = await pool.query(`
      SELECT EXISTS (
        SELECT FROM information_schema.tables 
        WHERE table_name = 'products'
      );
    `);
    
    if (!tableCheck.rows[0].exists) {
      return res.json({ 
        error: 'products table does not exist',
        message: 'Please create the products table first'
      });
    }

    // Tablo varsa içeriğini getir
    const result = await pool.query('SELECT * FROM products LIMIT 5');
    
    // Kolonları da kontrol et
    const columnCheck = await pool.query(`
      SELECT column_name, data_type 
      FROM information_schema.columns 
      WHERE table_name = 'products'
      ORDER BY ordinal_position;
    `);
    
    res.json({
      tableExists: true,
      count: result.rows.length,
      columns: columnCheck.rows,
      sampleData: result.rows
    });
  } catch (err) {
    console.error('Products check error:', err);
    res.status(500).json({ 
      error: 'Database error',
      details: err.message 
    });
  }
});

// Products tablosunu oluştur endpoint'i
app.get('/api/create-products-table', async (req, res) => {
  try {
    await pool.query(`
      CREATE TABLE IF NOT EXISTS products (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        name VARCHAR(255) NOT NULL,
        description TEXT,
        price DECIMAL(10,2) NOT NULL,
        category_id UUID REFERENCES categories(id),
        image_url TEXT,
        is_popular BOOLEAN DEFAULT false,
        is_available BOOLEAN DEFAULT true,
        ingredients JSONB DEFAULT '[]'::jsonb,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    `);

    res.json({ 
      success: true,
      message: 'Products table created successfully'
    });
  } catch (err) {
    console.error('Create products table error:', err);
    res.status(500).json({ 
      error: 'Database error',
      details: err.message 
    });
  }
});

// Products tablosunu düzelt (active -> is_available)
app.get('/api/fix-products-table', async (req, res) => {
  try {
    // Önce is_available kolonu var mı kontrol et
    const columnCheck = await pool.query(`
      SELECT column_name 
      FROM information_schema.columns 
      WHERE table_name = 'products' AND column_name = 'is_available';
    `);
    
    if (columnCheck.rows.length === 0) {
      // is_available kolonu yoksa ekle
      await pool.query(`
        ALTER TABLE products ADD COLUMN is_available BOOLEAN DEFAULT true;
      `);
    }
    
    // Eğer active kolonu varsa, verilerini is_available'a kopyala ve sil
    const activeColumnCheck = await pool.query(`
      SELECT column_name 
      FROM information_schema.columns 
      WHERE table_name = 'products' AND column_name = 'active';
    `);
    
    if (activeColumnCheck.rows.length > 0) {
      await pool.query(`
        UPDATE products SET is_available = active WHERE is_available IS NULL;
      `);
      await pool.query(`
        ALTER TABLE products DROP COLUMN active;
      `);
    }

    res.json({ 
      success: true,
      message: 'Products table schema fixed successfully'
    });
  } catch (err) {
    console.error('Fix products table error:', err);
    res.status(500).json({ 
      error: 'Database error',
      details: err.message 
    });
  }
});

// Yeni slider ekle
app.post('/api/sliders', async (req, res) => {
  try {
    const { title, description, image_url, link_url, is_active, sort_order } = req.body;
    
    const result = await pool.query(
      `INSERT INTO sliders (title, description, image_url, link_url, is_active, sort_order) 
       VALUES ($1, $2, $3, $4, $5, $6) RETURNING *`,
      [title, description, image_url, link_url, is_active !== false, sort_order || 0]
    );
    
    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error('Error creating slider:', err);
    res.status(500).json({ error: 'Internal server error', details: err.message });
  }
});

// Slider güncelle
app.put('/api/sliders/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const { title, description, image_url, link_url, is_active, sort_order } = req.body;
    
    const result = await pool.query(
      `UPDATE sliders 
       SET title = $1, description = $2, image_url = $3, link_url = $4, is_active = $5, sort_order = $6, updated_at = NOW()
       WHERE id = $7 RETURNING *`,
      [title, description, image_url, link_url, is_active !== false, sort_order || 0, id]
    );
    
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Slider not found' });
    }
    
    res.json(result.rows[0]);
  } catch (err) {
    console.error('Error updating slider:', err);
    res.status(500).json({ error: 'Internal server error', details: err.message });
  }
});

// Slider sil
app.delete('/api/sliders/:id', async (req, res) => {
  try {
    const { id } = req.params;
    
    const result = await pool.query('DELETE FROM sliders WHERE id = $1 RETURNING *', [id]);
    
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Slider not found' });
    }
    
    res.json({ message: 'Slider deleted successfully' });
  } catch (err) {
    console.error('Error deleting slider:', err);
    res.status(500).json({ error: 'Internal server error', details: err.message });
  }
});

// Slider sıralama güncelle
app.put('/api/sliders/:id/order', async (req, res) => {
  try {
    const { id } = req.params;
    const { sort_order } = req.body;
    
    const result = await pool.query(
      'UPDATE sliders SET sort_order = $1, updated_at = NOW() WHERE id = $2 RETURNING *',
      [sort_order, id]
    );
    
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Slider not found' });
    }
    
    res.json(result.rows[0]);
  } catch (err) {
    console.error('Error updating slider order:', err);
    res.status(500).json({ error: 'Internal server error', details: err.message });
  }
});

// Kullanıcı kampanya takibi - Kullanıcının tüm kampanya ilerlemesini getir
app.get('/api/user-campaign-progress/:userId', async (req, res) => {
  try {
    const { userId } = req.params;
    console.log(`📡 Get user campaign progress for user ID: ${userId}`);
    const result = await pool.query(`
      SELECT ucp.*, c.title as campaign_title, c.description as campaign_description, 
             c.image_url as campaign_image, c.campaign_type, c.required_count, c.reward_count,
             c.start_date, c.end_date, c.is_active
      FROM user_campaign_progress ucp
      JOIN campaigns c ON ucp.campaign_id = c.id
      WHERE ucp.user_id = $1 AND c.is_active = true
      ORDER BY ucp.created_at DESC
    `, [userId]);
    res.json(result.rows);
  } catch (err) {
    console.error('❌ Error getting user campaign progress:', err);
    res.status(500).json({ error: 'Internal server error', details: err.message });
  }
});

// Kullanıcı kampanya takibi - Belirli bir kampanya için ilerleme getir
app.get('/api/user-campaign-progress/:userId/:campaignId', async (req, res) => {
  try {
    const { userId, campaignId } = req.params;
    console.log(`📡 Get user campaign progress for user ${userId}, campaign ${campaignId}`);
    
    const result = await pool.query(`
      SELECT ucp.*, c.title as campaign_title, c.description as campaign_description, 
             c.image_url as campaign_image, c.campaign_type, c.required_count, c.reward_count,
             c.start_date, c.end_date, c.is_active
      FROM user_campaign_progress ucp
      JOIN campaigns c ON ucp.campaign_id = c.id
      WHERE ucp.user_id = $1 AND ucp.campaign_id = $2
    `, [userId, campaignId]);
    
    if (result.rows.length === 0) {
      // Kullanıcının bu kampanya için kaydı yoksa yeni kayıt oluştur
      const insertResult = await pool.query(`
        INSERT INTO user_campaign_progress (user_id, campaign_id, current_count, is_completed)
        VALUES ($1, $2, 0, false)
        RETURNING *
      `, [userId, campaignId]);
      
      console.log(`✅ Created new campaign progress for user ${userId}, campaign ${campaignId}`);
      res.json(insertResult.rows[0]);
    } else {
      console.log(`✅ Found existing campaign progress for user ${userId}, campaign ${campaignId}`);
      res.json(result.rows[0]);
    }
  } catch (err) {
    console.error('❌ Error getting user campaign progress:', err);
    res.status(500).json({ error: 'Internal server error', details: err.message });
  }
});

// Kullanıcı kampanya takibi - İlerlemeyi güncelle (sipariş tamamlandığında)
app.post('/api/user-campaign-progress/:userId/:campaignId/increment', async (req, res) => {
  try {
    const { userId, campaignId } = req.params;
    console.log(`📡 Increment campaign progress for user ${userId}, campaign ${campaignId}`);
    
    // Önce mevcut ilerlemeyi kontrol et
    const currentProgress = await pool.query(`
      SELECT ucp.*, c.required_count, c.reward_count
      FROM user_campaign_progress ucp
      JOIN campaigns c ON ucp.campaign_id = c.id
      WHERE ucp.user_id = $1 AND ucp.campaign_id = $2
    `, [userId, campaignId]);
    
    if (currentProgress.rows.length === 0) {
      return res.status(404).json({ error: 'Campaign progress not found' });
    }
    
    const progress = currentProgress.rows[0];
    const campaign = currentProgress.rows[0];
    
    // Eğer kampanya zaten tamamlanmışsa hata döndür
    if (progress.is_completed) {
      return res.status(400).json({ error: 'Campaign already completed' });
    }
    
    // Sayaç artır
    const newCount = progress.current_count + 1;
    const isCompleted = newCount >= campaign.required_count;
    
    const updateResult = await pool.query(`
      UPDATE user_campaign_progress 
      SET current_count = $1, 
          is_completed = $2, 
          completed_at = $3,
          updated_at = NOW()
      WHERE user_id = $4 AND campaign_id = $5
      RETURNING *
    `, [
      newCount, 
      isCompleted, 
      isCompleted ? new Date() : null,
      userId, 
      campaignId
    ]);
    
    console.log(`✅ Campaign progress updated for user ${userId}, campaign ${campaignId}: ${newCount}/${campaign.required_count}`);
    res.json(updateResult.rows[0]);
  } catch (err) {
    console.error('❌ Error incrementing campaign progress:', err);
    res.status(500).json({ error: 'Internal server error', details: err.message });
  }
});

// Kullanıcı kampanya takibi - Kampanya tamamlandığında ödül ver
app.post('/api/user-campaign-progress/:userId/:campaignId/claim-reward', async (req, res) => {
  try {
    const { userId, campaignId } = req.params;
    console.log(`📡 Claim reward for user ${userId}, campaign ${campaignId}`);
    
    // Kampanya ilerlemesini kontrol et
    const progress = await pool.query(`
      SELECT ucp.*, c.required_count, c.reward_count, c.reward_product_id
      FROM user_campaign_progress ucp
      JOIN campaigns c ON ucp.campaign_id = c.id
      WHERE ucp.user_id = $1 AND ucp.campaign_id = $2
    `, [userId, campaignId]);
    
    if (progress.rows.length === 0) {
      return res.status(404).json({ error: 'Campaign progress not found' });
    }
    
    const userProgress = progress.rows[0];
    const campaign = progress.rows[0];
    
    // Kampanya tamamlanmış mı kontrol et
    if (!userProgress.is_completed) {
      return res.status(400).json({ error: 'Campaign not completed yet' });
    }
    
    // Ödül zaten alınmış mı kontrol et (completed_at null değilse alınmış)
    if (userProgress.completed_at != null) {
      return res.status(400).json({ error: 'Reward already claimed' });
    }
    
    // Ödülü ver (completed_at'i güncelle)
    const updateResult = await pool.query(`
      UPDATE user_campaign_progress 
      SET completed_at = NOW(), updated_at = NOW()
      WHERE user_id = $1 AND campaign_id = $2
      RETURNING *
    `, [userId, campaignId]);
    
    console.log(`✅ Reward claimed for user ${userId}, campaign ${campaignId}`);
    res.json({
      success: true,
      message: 'Reward claimed successfully',
      progress: updateResult.rows[0],
      reward: {
        productId: campaign.reward_product_id,
        count: campaign.reward_count
      }
    });
  } catch (err) {
    console.error('❌ Error claiming reward:', err);
    res.status(500).json({ error: 'Internal server error', details: err.message });
  }
});

// --- STORIES ENDPOINTS ---

// Tüm hikayeleri listele
app.get('/api/stories', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM stories ORDER BY display_order ASC, created_at DESC');
    res.json(result.rows);
  } catch (error) {
    res.status(500).json({ error: 'Veritabanı hatası', details: error.message });
  }
});

// Yeni hikaye ekle
app.post('/api/stories', async (req, res) => {
  const { title, description, image_url, display_order, is_active } = req.body;
  try {
    const result = await pool.query(
      'INSERT INTO stories (title, description, image_url, display_order, is_active) VALUES ($1, $2, $3, $4, $5) RETURNING *',
      [title, description, image_url, display_order, is_active]
    );
    res.status(201).json(result.rows[0]);
  } catch (error) {
    res.status(500).json({ error: 'Veritabanı hatası', details: error.message });
  }
});

// Hikaye güncelle
app.put('/api/stories/:id', async (req, res) => {
  const { id } = req.params;
  const { title, description, image_url, display_order, is_active } = req.body;
  try {
    const result = await pool.query(
      'UPDATE stories SET title = $1, description = $2, image_url = $3, display_order = $4, is_active = $5, updated_at = NOW() WHERE id = $6 RETURNING *',
      [title, description, image_url, display_order, is_active, id]
    );
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Hikaye bulunamadı' });
    }
    res.json(result.rows[0]);
  } catch (error) {
    res.status(500).json({ error: 'Veritabanı hatası', details: error.message });
  }
});

// Hikaye sil
app.delete('/api/stories/:id', async (req, res) => {
  const { id } = req.params;
  try {
    const result = await pool.query('DELETE FROM stories WHERE id = $1 RETURNING *', [id]);
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Hikaye bulunamadı' });
    }
    res.json({ message: 'Hikaye başarıyla silindi' });
  } catch (error) {
    res.status(500).json({ error: 'Veritabanı hatası', details: error.message });
  }
});

// --- STORY ITEMS ENDPOINTS ---

// Tüm story item'ları listele (veya story_id ile filtrele)
app.get('/api/story-items', async (req, res) => {
  const { story_id } = req.query;
  try {
    let result;
    if (story_id) {
      result = await pool.query('SELECT * FROM story_items WHERE story_id = $1 ORDER BY display_order ASC, created_at DESC', [story_id]);
    } else {
      result = await pool.query('SELECT * FROM story_items ORDER BY display_order ASC, created_at DESC');
    }
    res.json(result.rows);
  } catch (error) {
    res.status(500).json({ error: 'Veritabanı hatası', details: error.message });
  }
});

// Yeni story item ekle
app.post('/api/story-items', async (req, res) => {
  const { story_id, image_url, description, display_order, is_active } = req.body;
  try {
    const result = await pool.query(
      'INSERT INTO story_items (story_id, image_url, description, display_order, is_active) VALUES ($1, $2, $3, $4, $5) RETURNING *',
      [story_id, image_url, description, display_order, is_active]
    );
    res.status(201).json(result.rows[0]);
  } catch (error) {
    res.status(500).json({ error: 'Veritabanı hatası', details: error.message });
  }
});

// Story item güncelle
app.put('/api/story-items/:id', async (req, res) => {
  const { id } = req.params;
  const { story_id, image_url, description, display_order, is_active } = req.body;
  try {
    const result = await pool.query(
      'UPDATE story_items SET story_id = $1, image_url = $2, description = $3, display_order = $4, is_active = $5, updated_at = NOW() WHERE id = $6 RETURNING *',
      [story_id, image_url, description, display_order, is_active, id]
    );
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Story item bulunamadı' });
    }
    res.json(result.rows[0]);
  } catch (error) {
    res.status(500).json({ error: 'Veritabanı hatası', details: error.message });
  }
});

// Story item sil
app.delete('/api/story-items/:id', async (req, res) => {
  const { id } = req.params;
  try {
    const result = await pool.query('DELETE FROM story_items WHERE id = $1 RETURNING *', [id]);
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Story item bulunamadı' });
    }
    res.json({ message: 'Story item başarıyla silindi' });
  } catch (error) {
    res.status(500).json({ error: 'Veritabanı hatası', details: error.message });
  }
});

// Belirli bir hikayeye ait TÜM story item'ları sil
app.delete('/api/story-items', async (req, res) => {
  const { story_id } = req.query;
  if (!story_id) return res.status(400).json({ error: 'story_id gerekli' });
  try {
    await pool.query('DELETE FROM story_items WHERE story_id = $1', [story_id]);
    res.json({ success: true, message: 'Tüm story item\'lar silindi' });
  } catch (error) {
    res.status(500).json({ error: 'Veritabanı hatası', details: error.message });
  }
});

// Sunucuyu başlat
app.listen(port, () => {
  console.log(`Server is running on port ${port}`);
}); 