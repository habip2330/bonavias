import express, { Request, Response, NextFunction, RequestHandler } from 'express';
import cors from 'cors';
import { Pool, QueryResult } from 'pg';
import dotenv from 'dotenv';
import multer from 'multer';
import path from 'path';
import fs from 'fs';
import admin from 'firebase-admin';

dotenv.config();

// Firebase Admin SDK başlat
try {
  const serviceAccount = require('../firebase-service-account.json');
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    projectId: 'bona-5d3a3',
  });
  console.log('Firebase Admin SDK başarıyla başlatıldı');
} catch (error) {
  console.log('Firebase Admin SDK zaten başlatılmış veya hata:', error);
}

// Database connection pool
const pool = new Pool({
  connectionString: process.env.DATABASE_URL || 'postgresql://postgres.wljqsddspfwobbuunqyn:bonavias2002@aws-0-eu-central-1.pooler.supabase.com:6543/postgres',
  ssl: { rejectUnauthorized: false },
});

const app = express();
const port = process.env.PORT || 3001;

// JSON body parser middleware (eksikse ekle)
app.use(express.json());

// Multer ayarları ve uploads klasörü (EN ÜSTE ALINDI)
const uploadsDir = path.join(__dirname, '../uploads');
if (!fs.existsSync(uploadsDir)) {
  fs.mkdirSync(uploadsDir);
}
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, uploadsDir);
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, uniqueSuffix + '-' + file.originalname);
  }
});
const upload = multer({ storage });

// Upload endpoint (EN ÜSTE ALINDI)
app.post('/api/upload', upload.single('image'), (req: any, res: Response) => {
  console.log('UPLOAD DEBUG:', req.file, req.body);
  if (!req.file) return res.status(400).json({ error: 'Dosya yüklenemedi' });
  const fileUrl = `http://localhost:3001/uploads/${req.file.filename}`;
  res.json({ url: fileUrl });
});

// Multer hata yakalayıcı middleware
app.use((err: any, req: Request, res: Response, next: NextFunction) => {
  if (err instanceof multer.MulterError) {
    console.error('Multer error:', err);
    return res.status(400).json({ error: err.message });
  }
  next(err);
});

// Diğer middleware'ler (upload endpointinden SONRA)
app.use(cors({
  origin: 'http://localhost:3000',
  credentials: true
}));

// Add request logging middleware
app.use((req: Request, res: Response, next: NextFunction) => {
  console.log(`${req.method} ${req.path}`, {
    body: req.body,
    params: req.params,
    query: req.query
  });
  next();
});

// Statik dosya servisi
app.use('/uploads', express.static(path.join(__dirname, '../uploads')));

// Test database connection and create tables if they don't exist
const initializeDatabase = async () => {
  let client;
  try {
    client = await pool.connect();
    console.log('Connected to PostgreSQL database');

    // Create tables
    await client.query(`
      CREATE TABLE IF NOT EXISTS categories (
        id SERIAL PRIMARY KEY,
        name VARCHAR(255) NOT NULL,
        description TEXT,
        is_active BOOLEAN DEFAULT true,
        image_url TEXT,
        created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
      );

      CREATE TABLE IF NOT EXISTS campaigns (
        id SERIAL PRIMARY KEY,
        title VARCHAR(255) NOT NULL,
        description TEXT,
        discount DECIMAL(5,2) NOT NULL,
        start_date TIMESTAMP WITH TIME ZONE NOT NULL,
        end_date TIMESTAMP WITH TIME ZONE NOT NULL,
        is_active BOOLEAN DEFAULT true,
        image_url TEXT,
        created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
      );
    `);
    console.log('Database tables created successfully');

    // Insert some sample data
    // await client.query(`
    //   INSERT INTO categories (name, description, image_url, sort_order)
    //   VALUES 
    //     ('Kategori 1', 'Açıklama 1', 'https://example.com/image1.jpg', 1),
    //     ('Kategori 2', 'Açıklama 2', 'https://example.com/image2.jpg', 2)
    //   ON CONFLICT DO NOTHING;
    // `);
    // console.log('Sample data inserted successfully');

  } catch (err) {
    console.error('Database initialization error:', err);
    process.exit(1);
  } finally {
    if (client) {
      client.release();
    }
  }
};

// Initialize database
initializeDatabase();

// Error handling middleware
app.use((err: Error, req: Request, res: Response, next: NextFunction) => {
  console.error(err.stack);
  res.status(500).json({ error: 'Bir hata oluştu!' });
});

// Health check endpoint
app.get('/api/health', (req: Request, res: Response) => {
  res.json({ status: 'OK' });
});

// Kategoriler endpoint'leri
const getCategories: RequestHandler = async (req, res, next) => {
  try {
    const result = await pool.query('SELECT * FROM categories ORDER BY id');
    res.json(result.rows);
  } catch (error) {
    next(error);
  }
};

const createCategory: RequestHandler = async (req, res, next) => {
  const { name, description, image_url, is_active } = req.body;
  console.log('Received category data:', { name, description, image_url, is_active });
  try {
    const result = await pool.query(
      'INSERT INTO categories (name, description, image_url, is_active) VALUES ($1, $2, $3, $4) RETURNING *',
      [name, description, image_url, is_active]
    );
    console.log('Category created:', result.rows[0]);
    res.status(201).json(result.rows[0]);
  } catch (error) {
    console.error('Error creating category:', error);
    next(error);
  }
};

const updateCategory: RequestHandler = async (req, res, next) => {
  const { id } = req.params;
  const { name, description, image_url, is_active } = req.body;
  console.log('Updating category:', { id, name, description, image_url, is_active });
  try {
    const result = await pool.query(
      'UPDATE categories SET name = $1, description = $2, image_url = $3, is_active = $4, updated_at = CURRENT_TIMESTAMP WHERE id = $5 RETURNING *',
      [name, description, image_url, is_active, id]
    );
    if (result.rows.length === 0) {
      console.log('Category not found:', id);
      res.status(404).json({ error: 'Kategori bulunamadı' });
    } else {
      console.log('Category updated:', result.rows[0]);
      res.json(result.rows[0]);
    }
  } catch (error) {
    console.error('Error updating category:', error);
    next(error);
  }
};

const deleteCategory: RequestHandler = async (req, res, next) => {
  const { id } = req.params;
  try {
    const result = await pool.query('DELETE FROM categories WHERE id = $1 RETURNING *', [id]);
    if (result.rows.length === 0) {
      res.status(404).json({ error: 'Kategori bulunamadı' });
    } else {
      res.json({ message: 'Kategori başarıyla silindi' });
    }
  } catch (error) {
    next(error);
  }
};

// Kampanyalar endpoint'leri
const getCampaigns: RequestHandler = async (req, res, next) => {
  try {
    const result = await pool.query('SELECT * FROM campaigns');
    res.json(result.rows);
  } catch (error) {
    next(error);
  }
};

const createCampaign: RequestHandler = async (req, res, next) => {
  const { title, description, start_date, end_date, is_active, image_url } = req.body;
  try {
    const result = await pool.query(
      'INSERT INTO campaigns (title, description, start_date, end_date, is_active, image_url) VALUES ($1, $2, $3, $4, $5, $6) RETURNING *',
      [title, description, start_date, end_date, is_active, image_url]
    );
    res.status(201).json(result.rows[0]);
  } catch (error) {
    console.error('Error creating campaign:', error);
    next(error);
  }
};

const updateCampaign: RequestHandler = async (req, res, next) => {
  const { id } = req.params;
  const { title, description, start_date, end_date, is_active, image_url } = req.body;
  try {
    const result = await pool.query(
      'UPDATE campaigns SET title = $1, description = $2, start_date = $3, end_date = $4, is_active = $5, image_url = $6 WHERE id = $7 RETURNING *',
      [title, description, start_date, end_date, is_active, image_url, id]
    );
    if (result.rows.length === 0) {
      res.status(404).json({ error: 'Kampanya bulunamadı' });
    } else {
      res.json(result.rows[0]);
    }
  } catch (error) {
    console.error('Error updating campaign:', error);
    next(error);
  }
};

const deleteCampaign: RequestHandler = async (req, res, next) => {
  const { id } = req.params;
  try {
    const result = await pool.query('DELETE FROM campaigns WHERE id = $1 RETURNING *', [id]);
    if (result.rows.length === 0) {
      res.status(404).json({ error: 'Kampanya bulunamadı' });
    } else {
      res.json({ message: 'Kampanya başarıyla silindi' });
    }
  } catch (error) {
    next(error);
  }
};

// BRANCHES ENDPOINTLERİ
app.get('/api/branches', async (req, res, next) => {
  try {
    const result = await pool.query('SELECT * FROM branches ORDER BY id');
    res.json(result.rows);
  } catch (error) { next(error); }
});
app.post('/api/branches', async (req, res, next) => {
  const { name, address, phone, email, latitude, longitude, opening_hours, is_active } = req.body;
  try {
    const result = await pool.query(
      'INSERT INTO branches (name, address, phone, email, latitude, longitude, opening_hours, is_active) VALUES ($1,$2,$3,$4,$5,$6,$7,$8) RETURNING *',
      [name, address, phone, email, latitude, longitude, opening_hours, is_active]
    );
    res.status(201).json(result.rows[0]);
  } catch (error) { next(error); }
});
app.put('/api/branches/:id', async (req, res, next) => {
  const { id } = req.params;
  const { name, address, phone, email, latitude, longitude, opening_hours, is_active } = req.body;
  try {
    const result = await pool.query(
      'UPDATE branches SET name=$1, address=$2, phone=$3, email=$4, latitude=$5, longitude=$6, opening_hours=$7, is_active=$8, updated_at=NOW() WHERE id=$9 RETURNING *',
      [name, address, phone, email, latitude, longitude, opening_hours, is_active, id]
    );
    res.json(result.rows[0]);
  } catch (error) { next(error); }
});
app.delete('/api/branches/:id', async (req, res, next) => {
  const { id } = req.params;
  try {
    await pool.query('DELETE FROM branches WHERE id=$1', [id]);
    res.json({ message: 'Branch deleted' });
  } catch (error) { next(error); }
});

// FAQ ENDPOINTLERİ
app.get('/api/faqs', async (req, res, next) => {
  try {
    const result = await pool.query('SELECT * FROM faqs ORDER BY id');
    res.json(result.rows);
  } catch (error) { next(error); }
});
app.post('/api/faqs', async (req, res, next) => {
  const { question, answer, category_id, display_order, is_active } = req.body;
  try {
    const result = await pool.query(
      'INSERT INTO faqs (question, answer, category_id, display_order, is_active) VALUES ($1,$2,$3,$4,$5) RETURNING *',
      [question, answer, category_id, display_order, is_active]
    );
    res.status(201).json(result.rows[0]);
  } catch (error) { next(error); }
});
app.put('/api/faqs/:id', async (req, res, next) => {
  const { id } = req.params;
  const { question, answer, category_id, display_order, is_active } = req.body;
  try {
    const result = await pool.query(
      'UPDATE faqs SET question=$1, answer=$2, category_id=$3, display_order=$4, is_active=$5, updated_at=NOW() WHERE id=$6 RETURNING *',
      [question, answer, category_id, display_order, is_active, id]
    );
    res.json(result.rows[0]);
  } catch (error) { next(error); }
});
app.delete('/api/faqs/:id', async (req, res, next) => {
  const { id } = req.params;
  try {
    await pool.query('DELETE FROM faqs WHERE id=$1', [id]);
    res.json({ message: 'FAQ deleted' });
  } catch (error) { next(error); }
});

// FCM BİLDİRİM GÖNDERME FONKSİYONU
const sendPushNotification = async (tokens: string[], title: string, body: string, data?: any) => {
  console.log('sendPushNotification fonksiyonu çağrıldı.');
  try {
    const message = {
      notification: {
        title: title,
        body: body,
      },
      data: data || {},
      tokens: tokens,
    };

    const response = await admin.messaging().sendEachForMulticast(message);
    console.log('FCM Response:', response);
    return response;
  } catch (error) {
    console.error('FCM gönderme hatası:', error);
    throw error;
  }
};

// Tüm kullanıcılara bildirim gönder
const sendNotificationToAllUsers = async (title: string, body: string, data?: any) => {
  console.log('sendNotificationToAllUsers fonksiyonu çağrıldı.');
  try {
    // Firestore'dan tüm FCM token'larını al
    const usersSnapshot = await admin.firestore().collection('users').get();
    const tokens: string[] = [];
    
    usersSnapshot.forEach((doc) => {
      const userData = doc.data();
      if (userData.fcm_token) {
        tokens.push(userData.fcm_token);
      }
    });

    if (tokens.length > 0) {
      console.log('FCM token sayısı:', tokens.length);
      return await sendPushNotification(tokens, title, body, data);
    } else {
      console.log('Gönderilecek FCM token bulunamadı');
      return null;
    }
  } catch (error) {
    console.error('Toplu bildirim gönderme hatası:', error);
    throw error;
  }
};

// NOTIFICATIONS ENDPOINTLERİ
app.get('/api/notifications', async (req, res, next) => {
  try {
    const result = await pool.query('SELECT * FROM notifications ORDER BY id');
    res.json(result.rows);
  } catch (error) { next(error); }
});

app.post('/api/notifications', async (req, res, next) => {
  console.log('GELEN BODY:', req.body); // Gelen body'yi logla
  const { title, message, type, is_read, send_push, target_audience, scheduled_for, expires_at, is_active } = req.body;
  try {
    const result = await pool.query(
      'INSERT INTO notifications (title, message, type, is_read, target_audience, scheduled_for, expires_at, is_active) VALUES ($1,$2,$3,$4,$5,$6,$7,$8) RETURNING *',
      [title, message, type, is_read, target_audience || 'all', scheduled_for || new Date(), expires_at || new Date(Date.now() + 30 * 24 * 60 * 60 * 1000), is_active !== undefined ? is_active : true]
    );
    
    // Eğer push notification gönderilmesi isteniyorsa
    if (send_push) {
      console.log('PUSH FONKSİYONU ÇAĞRILIYOR!!!');
      try {
        await sendNotificationToAllUsers(title, message, {
          type: type,
          notification_id: result.rows[0].id.toString(),
        });
        console.log('Push notification başarıyla gönderildi');
      } catch (pushError) {
        console.error('Push notification gönderme hatası:', pushError);
      }
    } else {
      console.log('send_push parametresi false veya yok, push fonksiyonu çağrılmadı.');
    }
    
    res.status(201).json(result.rows[0]);
  } catch (error) { 
    console.error('Notification ekleme hatası:', error);
    next(error); 
  }
});
app.put('/api/notifications/:id', async (req, res, next) => {
  const { id } = req.params;
  const { title, message, type, is_read } = req.body;
  try {
    const result = await pool.query(
      'UPDATE notifications SET title=$1, message=$2, type=$3, is_read=$4 WHERE id=$5 RETURNING *',
      [title, message, type, is_read, id]
    );
    res.json(result.rows[0]);
  } catch (error) { next(error); }
});
app.delete('/api/notifications/:id', async (req, res, next) => {
  const { id } = req.params;
  try {
    await pool.query('DELETE FROM notifications WHERE id=$1', [id]);
    res.json({ message: 'Notification deleted' });
  } catch (error) { next(error); }
});

// PRODUCTS ENDPOINTLERİ
app.get('/api/products', async (req, res, next) => {
  try {
    const result = await pool.query('SELECT * FROM products ORDER BY id');
    res.json(result.rows);
  } catch (error) { next(error); }
});
app.post('/api/products', async (req, res, next) => {
  const { name, description, price, category_id, image_url, is_available } = req.body;
  try {
    const result = await pool.query(
      'INSERT INTO products (name, description, price, category_id, image_url, is_available) VALUES ($1,$2,$3,$4,$5,$6) RETURNING *',
      [name, description, price, category_id, image_url, is_available]
    );
    res.status(201).json(result.rows[0]);
  } catch (error) { next(error); }
});
app.put('/api/products/:id', async (req, res, next) => {
  const { id } = req.params;
  const { name, description, price, category_id, image_url, is_available } = req.body;
  try {
    const result = await pool.query(
      'UPDATE products SET name=$1, description=$2, price=$3, category_id=$4, image_url=$5, is_available=$6, updated_at=NOW() WHERE id=$7 RETURNING *',
      [name, description, price, category_id, image_url, is_available, id]
    );
    res.json(result.rows[0]);
  } catch (error) { next(error); }
});
app.delete('/api/products/:id', async (req, res, next) => {
  const { id } = req.params;
  try {
    await pool.query('DELETE FROM products WHERE id=$1', [id]);
    res.json({ message: 'Product deleted' });
  } catch (error) { next(error); }
});

// SLIDER ENDPOINTLERİ
app.get('/api/slider', async (req, res, next) => {
  try {
    const result = await pool.query('SELECT * FROM slider ORDER BY display_order, id');
    res.json(result.rows);
  } catch (error) { next(error); }
});
app.post('/api/slider', async (req, res, next) => {
  const { title, description, image_url, link, display_order, is_active } = req.body;
  try {
    const result = await pool.query(
      'INSERT INTO slider (title, description, image_url, link, display_order, is_active) VALUES ($1,$2,$3,$4,$5,$6) RETURNING *',
      [title, description, image_url, link, display_order, is_active]
    );
    res.status(201).json(result.rows[0]);
  } catch (error) { next(error); }
});
app.put('/api/slider/:id', async (req, res, next) => {
  const { id } = req.params;
  const { title, description, image_url, link, display_order, is_active } = req.body;
  try {
    const result = await pool.query(
      'UPDATE slider SET title=$1, description=$2, image_url=$3, link=$4, display_order=$5, is_active=$6, updated_at=NOW() WHERE id=$7 RETURNING *',
      [title, description, image_url, link, display_order, is_active, id]
    );
    res.json(result.rows[0]);
  } catch (error) { next(error); }
});
app.delete('/api/slider/:id', async (req, res, next) => {
  const { id } = req.params;
  try {
    await pool.query('DELETE FROM slider WHERE id=$1', [id]);
    res.json({ message: 'Slider deleted' });
  } catch (error) { next(error); }
});

// --- STORIES ENDPOINTS ---

// List all stories
app.get('/api/stories', async (req, res, next) => {
  try {
    const result = await pool.query('SELECT * FROM stories ORDER BY display_order ASC, created_at DESC');
    res.json(result.rows);
  } catch (error) {
    next(error);
  }
});

// Create a new story
app.post('/api/stories', async (req, res, next) => {
  const { title, description, image_url, display_order, is_active } = req.body;
  try {
    const result = await pool.query(
      'INSERT INTO stories (title, description, image_url, display_order, is_active) VALUES ($1, $2, $3, $4, $5) RETURNING *',
      [title, description, image_url, display_order, is_active]
    );
    res.status(201).json(result.rows[0]);
  } catch (error) {
    next(error);
  }
});

// Update a story
app.put('/api/stories/:id', async (req, res, next) => {
  const { id } = req.params;
  const { title, description, image_url, display_order, is_active } = req.body;
  try {
    const result = await pool.query(
      'UPDATE stories SET title = $1, description = $2, image_url = $3, display_order = $4, is_active = $5, updated_at = CURRENT_TIMESTAMP WHERE id = $6 RETURNING *',
      [title, description, image_url, display_order, is_active, id]
    );
    if (result.rows.length === 0) {
      res.status(404).json({ error: 'Story not found' });
    } else {
      res.json(result.rows[0]);
    }
  } catch (error) {
    next(error);
  }
});

// Delete a story
app.delete('/api/stories/:id', async (req, res, next) => {
  const { id } = req.params;
  try {
    const result = await pool.query('DELETE FROM stories WHERE id = $1 RETURNING *', [id]);
    if (result.rows.length === 0) {
      res.status(404).json({ error: 'Story not found' });
    } else {
      res.json({ message: 'Story deleted successfully' });
    }
  } catch (error) {
    next(error);
  }
});

// --- STORY ITEMS ENDPOINTS ---

// List all story items, or filter by story_id
app.get('/api/story-items', async (req, res, next) => {
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
    next(error);
  }
});

// Create a new story item
app.post('/api/story-items', async (req, res, next) => {
  const { story_id, image_url, description, display_order, is_active } = req.body;
  try {
    const result = await pool.query(
      'INSERT INTO story_items (story_id, image_url, description, display_order, is_active) VALUES ($1, $2, $3, $4, $5) RETURNING *',
      [story_id, image_url, description, display_order, is_active]
    );
    res.status(201).json(result.rows[0]);
  } catch (error) {
    next(error);
  }
});

// Update a story item
app.put('/api/story-items/:id', async (req, res, next) => {
  const { id } = req.params;
  const { story_id, image_url, description, display_order, is_active } = req.body;
  try {
    const result = await pool.query(
      'UPDATE story_items SET story_id = $1, image_url = $2, description = $3, display_order = $4, is_active = $5, updated_at = CURRENT_TIMESTAMP WHERE id = $6 RETURNING *',
      [story_id, image_url, description, display_order, is_active, id]
    );
    if (result.rows.length === 0) {
      res.status(404).json({ error: 'Story item not found' });
    } else {
      res.json(result.rows[0]);
    }
  } catch (error) {
    next(error);
  }
});

// Delete a story item
app.delete('/api/story-items/:id', async (req, res, next) => {
  const { id } = req.params;
  try {
    const result = await pool.query('DELETE FROM story_items WHERE id = $1 RETURNING *', [id]);
    if (result.rows.length === 0) {
      res.status(404).json({ error: 'Story item not found' });
    } else {
      res.json({ message: 'Story item deleted successfully' });
    }
  } catch (error) {
    next(error);
  }
});

// Delete all story items for a story
app.delete('/api/story-items', async (req, res, next) => {
  const { story_id } = req.query;
  if (!story_id) return res.status(400).json({ error: 'story_id is required' });
  try {
    await pool.query('DELETE FROM story_items WHERE story_id = $1', [story_id]);
    res.json({ message: 'All story items deleted for story_id ' + story_id });
  } catch (error) {
    next(error);
  }
});

// Start server
app.listen(3001, '0.0.0.0', () => {
  console.log('Server is running on port 3001');
  console.log(`Health check available at http://localhost:${port}/api/health`);
}); 