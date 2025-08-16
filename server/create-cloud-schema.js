const { Pool } = require('pg');

// Cloud PostgreSQL bağlantısı (Vercel)
const cloudPool = new Pool({
  connectionString: 'postgresql://postgres.wljqsddspfwobbuunqyn:bonavias2002@aws-0-eu-central-1.pooler.supabase.com:6543/postgres',
  ssl: { rejectUnauthorized: false },
});

async function createCloudSchema() {
  try {
    console.log('🏗️ Cloud veritabanında tablolar oluşturuluyor...');
    
    const client = await cloudPool.connect();
    console.log('✅ Cloud veritabanına bağlandı');
    
    // UUID extension ekle
    await client.query('CREATE EXTENSION IF NOT EXISTS "uuid-ossp"');
    console.log('✅ UUID extension eklendi');
    
    // Categories tablosu
    await client.query(`
      CREATE TABLE IF NOT EXISTS categories (
        id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
        name VARCHAR(255) NOT NULL,
        description TEXT,
        image_url TEXT,
        is_active BOOLEAN DEFAULT true,
        sort_order INTEGER DEFAULT 0,
        created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
      )
    `);
    console.log('✅ Categories tablosu oluşturuldu');
    
    // Products tablosu
    await client.query(`
      CREATE TABLE IF NOT EXISTS products (
        id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
        name VARCHAR(255) NOT NULL,
        description TEXT,
        price DECIMAL(10,2) NOT NULL,
        category_id UUID REFERENCES categories(id),
        image_url TEXT,
        is_available BOOLEAN DEFAULT true,
        ingredients JSONB,
        created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
      )
    `);
    console.log('✅ Products tablosu oluşturuldu');
    
    // Branches tablosu
    await client.query(`
      CREATE TABLE IF NOT EXISTS branches (
        id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
        name VARCHAR(255) NOT NULL,
        address TEXT NOT NULL,
        location TEXT,
        phone VARCHAR(20),
        email VARCHAR(255),
        working_hours TEXT,
        is_active BOOLEAN DEFAULT true,
        latitude DOUBLE PRECISION,
        longitude DOUBLE PRECISION,
        created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
      )
    `);
    console.log('✅ Branches tablosu oluşturuldu');
    
    // Campaigns tablosu
    await client.query(`
      CREATE TABLE IF NOT EXISTS campaigns (
        id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
        title VARCHAR(255) NOT NULL,
        description TEXT,
        start_date DATE,
        end_date DATE,
        discount INTEGER,
        image_url TEXT,
        is_active BOOLEAN DEFAULT true,
        created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
      )
    `);
    console.log('✅ Campaigns tablosu oluşturuldu');
    
    // Users tablosu
    await client.query(`
      CREATE TABLE IF NOT EXISTS users (
        id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
        email VARCHAR(255) UNIQUE NOT NULL,
        password_hash VARCHAR(255),
        first_name VARCHAR(100),
        last_name VARCHAR(100),
        phone VARCHAR(20),
        is_active BOOLEAN DEFAULT true,
        created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
      )
    `);
    console.log('✅ Users tablosu oluşturuldu');
    
    // Orders tablosu
    await client.query(`
      CREATE TABLE IF NOT EXISTS orders (
        id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
        user_id UUID REFERENCES users(id),
        total_amount DECIMAL(10,2) NOT NULL,
        status VARCHAR(50) DEFAULT 'pending',
        created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
      )
    `);
    console.log('✅ Orders tablosu oluşturuldu');
    
    // Order items tablosu
    await client.query(`
      CREATE TABLE IF NOT EXISTS order_items (
        id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
        order_id UUID REFERENCES orders(id),
        product_id UUID REFERENCES products(id),
        quantity INTEGER NOT NULL,
        price DECIMAL(10,2) NOT NULL,
        created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
      )
    `);
    console.log('✅ Order items tablosu oluşturuldu');
    
    // Sliders tablosu
    await client.query(`
      CREATE TABLE IF NOT EXISTS sliders (
        id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
        title VARCHAR(255),
        description TEXT,
        image_url TEXT NOT NULL,
        link VARCHAR(500),
        sort_order INTEGER DEFAULT 0,
        is_active BOOLEAN DEFAULT true,
        created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
      )
    `);
    console.log('✅ Sliders tablosu oluşturuldu');
    
    // Stories tablosu
    await client.query(`
      CREATE TABLE IF NOT EXISTS stories (
        id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
        title VARCHAR(255),
        description TEXT,
        image_url TEXT,
        is_active BOOLEAN DEFAULT true,
        created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
      )
    `);
    console.log('✅ Stories tablosu oluşturuldu');
    
    // Notifications tablosu
    await client.query(`
      CREATE TABLE IF NOT EXISTS notifications (
        id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
        title VARCHAR(255) NOT NULL,
        message TEXT,
        type VARCHAR(50) DEFAULT 'info',
        is_read BOOLEAN DEFAULT false,
        created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
      )
    `);
    console.log('✅ Notifications tablosu oluşturuldu');
    
    // FAQs tablosu
    await client.query(`
      CREATE TABLE IF NOT EXISTS faqs (
        id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
        question TEXT NOT NULL,
        answer TEXT NOT NULL,
        category_id UUID,
        display_order INTEGER DEFAULT 0,
        is_active BOOLEAN DEFAULT true,
        created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
      )
    `);
    console.log('✅ FAQs tablosu oluşturuldu');
    
    // User favorites tablosu
    await client.query(`
      CREATE TABLE IF NOT EXISTS user_favorites (
        id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
        user_id UUID REFERENCES users(id),
        product_id UUID REFERENCES products(id),
        created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
        UNIQUE(user_id, product_id)
      )
    `);
    console.log('✅ User favorites tablosu oluşturuldu');
    
    // User addresses tablosu
    await client.query(`
      CREATE TABLE IF NOT EXISTS user_addresses (
        id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
        user_id UUID REFERENCES users(id),
        address TEXT NOT NULL,
        city VARCHAR(100),
        postal_code VARCHAR(20),
        is_default BOOLEAN DEFAULT false,
        created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
      )
    `);
    console.log('✅ User addresses tablosu oluşturuldu');
    
    // Branch ratings tablosu
    await client.query(`
      CREATE TABLE IF NOT EXISTS branch_ratings (
        id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
        user_id UUID REFERENCES users(id),
        branch_id UUID REFERENCES branches(id),
        rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
        comment TEXT,
        created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
      )
    `);
    console.log('✅ Branch ratings tablosu oluşturuldu');
    
    // User campaign progress tablosu
    await client.query(`
      CREATE TABLE IF NOT EXISTS user_campaign_progress (
        id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
        user_id UUID REFERENCES users(id),
        campaign_id UUID REFERENCES campaigns(id),
        progress INTEGER DEFAULT 0,
        completed BOOLEAN DEFAULT false,
        created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
      )
    `);
    console.log('✅ User campaign progress tablosu oluşturuldu');
    
    // Updated at trigger function
    await client.query(`
      CREATE OR REPLACE FUNCTION update_updated_at_column()
      RETURNS TRIGGER AS $$
      BEGIN
          NEW.updated_at = CURRENT_TIMESTAMP;
          RETURN NEW;
      END;
      $$ language 'plpgsql';
    `);
    console.log('✅ Updated at trigger function oluşturuldu');
    
    // Trigger'ları ekle
    const tablesWithUpdatedAt = ['categories', 'products', 'branches', 'campaigns', 'users', 'orders', 'sliders', 'stories', 'branch_ratings', 'user_campaign_progress'];
    
    for (const table of tablesWithUpdatedAt) {
      try {
        await client.query(`
          DROP TRIGGER IF EXISTS update_${table}_updated_at ON ${table};
          CREATE TRIGGER update_${table}_updated_at
              BEFORE UPDATE ON ${table}
              FOR EACH ROW
              EXECUTE FUNCTION update_updated_at_column();
        `);
        console.log(`  ✅ ${table} için trigger eklendi`);
      } catch (err) {
        console.log(`  ⚠️ ${table} trigger hatası:`, err.message);
      }
    }
    
    console.log('\n🎉 Cloud veritabanı şeması başarıyla oluşturuldu!');
    console.log('📋 Tüm tablolar ve trigger\'lar hazır');
    console.log('🚀 Şimdi veri migrasyonu yapabilirsiniz');
    
    client.release();
    
  } catch (err) {
    console.error('❌ Schema oluşturma hatası:', err.message);
  } finally {
    await cloudPool.end();
  }
}

createCloudSchema();
