const { Pool } = require('pg');

const pool = new Pool({
  user: 'postgres',
  host: 'localhost',
  database: 'bonavias',
  password: 'Habip2330@1',
  port: 5432,
});

async function checkDatabase() {
  try {
    console.log('🔌 Veritabanına bağlanılıyor...');
    
    // Test connection
    const client = await pool.connect();
    console.log('✅ Veritabanı bağlantısı başarılı!');
    
    // Check if tables exist
    const tablesResult = await client.query(`
      SELECT table_name 
      FROM information_schema.tables 
      WHERE table_schema = 'public'
      ORDER BY table_name;
    `);
    
    console.log('\n📋 Mevcut tablolar:');
    tablesResult.rows.forEach(row => {
      console.log(`  - ${row.table_name}`);
    });
    
    // Check products table
    console.log('\n🛍️ Ürünler tablosu kontrol ediliyor...');
    const productsResult = await client.query('SELECT COUNT(*) as count FROM products');
    console.log(`Toplam ürün sayısı: ${productsResult.rows[0].count}`);
    
    if (productsResult.rows[0].count > 0) {
      const products = await client.query('SELECT id, name, price, category_id FROM products LIMIT 5');
      console.log('\n📦 İlk 5 ürün:');
      products.rows.forEach(row => {
        console.log(`  ID: ${row.id}, İsim: ${row.name}, Fiyat: ${row.price}, Kategori ID: ${row.category_id}`);
      });
    } else {
      console.log('❌ Ürün tablosunda veri bulunamadı!');
    }
    
    // Check categories table
    console.log('\n🏷️ Kategoriler tablosu kontrol ediliyor...');
    const categoriesResult = await client.query('SELECT COUNT(*) as count FROM categories');
    console.log(`Toplam kategori sayısı: ${categoriesResult.rows[0].count}`);
    
    if (categoriesResult.rows[0].count > 0) {
      const categories = await client.query('SELECT id, name, description FROM categories LIMIT 5');
      console.log('\n📂 İlk 5 kategori:');
      categories.rows.forEach(row => {
        console.log(`  ID: ${row.id}, İsim: ${row.name}, Açıklama: ${row.description}`);
      });
    } else {
      console.log('❌ Kategori tablosunda veri bulunamadı!');
    }
    
    client.release();
    
  } catch (err) {
    console.error('❌ Hata:', err.message);
    if (err.code === 'ENOTFOUND') {
      console.error('🔍 Veritabanı sunucusu bulunamadı. Lütfen bağlantı bilgilerini kontrol edin.');
    } else if (err.code === 'ECONNREFUSED') {
      console.error('🚫 Bağlantı reddedildi. Lütfen veritabanı sunucusunun çalıştığından emin olun.');
    } else if (err.code === '28P01') {
      console.error('🔑 Kimlik doğrulama hatası. Lütfen kullanıcı adı ve şifreyi kontrol edin.');
    }
  } finally {
    await pool.end();
  }
}

checkDatabase(); 