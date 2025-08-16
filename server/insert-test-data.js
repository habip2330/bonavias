const { Pool } = require('pg');

const pool = new Pool({
  connectionString: process.env.DATABASE_URL || 'postgresql://postgres.wljqsddspfwobbuunqyn:bonavias2002@aws-0-eu-central-1.pooler.supabase.com:6543/postgres',
  ssl: { rejectUnauthorized: false },
});

async function insertTestData() {
  try {
    console.log('🔌 Veritabanına bağlanılıyor...');
    
    const client = await pool.connect();
    console.log('✅ Veritabanı bağlantısı başarılı!');
    
    // Check if data already exists
    const existingProducts = await client.query('SELECT COUNT(*) as count FROM products');
    const existingCategories = await client.query('SELECT COUNT(*) as count FROM categories');
    
    if (existingProducts.rows[0].count > 0 || existingCategories.rows[0].count > 0) {
      console.log('⚠️ Veritabanında zaten veri mevcut!');
      console.log(`Mevcut ürün sayısı: ${existingProducts.rows[0].count}`);
      console.log(`Mevcut kategori sayısı: ${existingCategories.rows[0].count}`);
      return;
    }
    
    console.log('📝 Test verisi ekleniyor...');
    
    // Insert Categories
    console.log('🏷️ Kategoriler ekleniyor...');
    await client.query(`
      INSERT INTO categories (name, description, image_url, is_active) VALUES
      ('Hot Drinks', 'Warm beverages including coffee and tea', 'https://placehold.co/200x200', true),
      ('Cold Drinks', 'Refreshing cold beverages', 'https://placehold.co/200x200', true),
      ('Food', 'Delicious food items', 'https://placehold.co/200x200', true)
    `);
    
    // Insert Products
    console.log('🛍️ Ürünler ekleniyor...');
    await client.query(`
      INSERT INTO products (name, description, price, category_id, image_url, is_available) VALUES
      ('Cappuccino', 'Classic Italian coffee with steamed milk foam', 4.50, 
          (SELECT id FROM categories WHERE name = 'Hot Drinks'),
          'https://placehold.co/200x200', true),
      ('Iced Latte', 'Cold coffee with milk and ice', 4.00,
          (SELECT id FROM categories WHERE name = 'Cold Drinks'),
          'https://placehold.co/200x200', true),
      ('Croissant', 'Buttery French pastry', 3.50,
          (SELECT id FROM categories WHERE name = 'Food'),
          'https://placehold.co/200x200', true)
    `);
    
    // Insert Campaigns
    console.log('🎯 Kampanyalar ekleniyor...');
    await client.query(`
      INSERT INTO campaigns (title, description, start_date, end_date, discount, image_url, is_active) VALUES
      ('Summer Special', 'Get 20% off on all cold drinks', CURRENT_DATE, 
          CURRENT_DATE + INTERVAL '30 days', 20, 
          'https://placehold.co/200x200', true)
    `);
    
    // Insert Branches
    console.log('🏪 Şubeler ekleniyor...');
    await client.query(`
      INSERT INTO branches (
          name, address, phone, email, latitude, longitude, 
          opening_hours, is_active
      ) VALUES (
          'Downtown Branch',
          '123 Main Street, Downtown',
          '+1 234 567 8900',
          'downtown@bonavias.com',
          40.7128,
          -74.0060,
          'Mon-Sun: 8:00 AM - 10:00 PM',
          true
      )
    `);
    
    console.log('✅ Test verisi başarıyla eklendi!');
    
    // Verify the data
    const finalProducts = await client.query('SELECT COUNT(*) as count FROM products');
    const finalCategories = await client.query('SELECT COUNT(*) as count FROM categories');
    
    console.log(`\n📊 Son durum:`);
    console.log(`  - Ürün sayısı: ${finalProducts.rows[0].count}`);
    console.log(`  - Kategori sayısı: ${finalCategories.rows[0].count}`);
    
    client.release();
    
  } catch (err) {
    console.error('❌ Hata:', err.message);
    if (err.code === '42P01') {
      console.error('🔍 Tablo bulunamadı! Lütfen önce veritabanı şemasını oluşturun.');
    } else if (err.code === '23505') {
      console.error('🔄 Veri zaten mevcut! Duplicate key hatası.');
    }
  } finally {
    await pool.end();
  }
}

insertTestData();
