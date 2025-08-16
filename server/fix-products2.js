const { Pool } = require('pg');

// PostgreSQL bağlantı ayarları
const pool = new Pool({
  user: 'postgres',
  host: 'localhost',
  database: 'bonavias',
  password: 'Habip2330@1',
  port: 5432,
});

async function fixProductsTable() {
  try {
    console.log('Products tablosuna ingredients kolonu ekleniyor...');
    
    // ingredients kolonu var mı kontrol et
    const columnCheck = await pool.query(`
      SELECT column_name 
      FROM information_schema.columns 
      WHERE table_name = 'products' AND column_name = 'ingredients';
    `);
    
    if (columnCheck.rows.length === 0) {
      console.log('ingredients kolonu ekleniyor...');
      await pool.query(`
        ALTER TABLE products ADD COLUMN ingredients JSONB DEFAULT '[]'::jsonb;
      `);
      console.log('ingredients kolonu eklendi.');
    } else {
      console.log('ingredients kolonu zaten mevcut.');
    }

    // Tablo yapısını kontrol et
    const finalCheck = await pool.query(`
      SELECT column_name, data_type 
      FROM information_schema.columns 
      WHERE table_name = 'products'
      ORDER BY ordinal_position;
    `);
    
    console.log('Products tablo yapısı:');
    finalCheck.rows.forEach(row => {
      console.log(`- ${row.column_name}: ${row.data_type}`);
    });
    
    console.log('Products tablosu başarıyla düzeltildi!');
  } catch (err) {
    console.error('Products tablo düzeltme hatası:', err);
  } finally {
    await pool.end();
  }
}

fixProductsTable(); 