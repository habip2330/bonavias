const { Pool } = require('pg');

// Local PostgreSQL bağlantısı
const localPool = new Pool({
  user: 'postgres',
  host: 'localhost',
  database: 'bonavias',
  password: 'Habip2330@1',
  port: 5432,
});

// Cloud PostgreSQL bağlantısı (Vercel)
const cloudPool = new Pool({
  connectionString: 'postgresql://postgres.wljqsddspfwobbuunqyn:bonavias2002@aws-0-eu-central-1.pooler.supabase.com:6543/postgres',
  ssl: { rejectUnauthorized: false },
});

async function migrateToCloud() {
  try {
    console.log('🚀 Veri migrasyonu başlıyor...');
    
    // Local veritabanına bağlan
    const localClient = await localPool.connect();
    console.log('✅ Local veritabanına bağlandı');
    
    // Cloud veritabanına bağlan
    const cloudClient = await cloudPool.connect();
    console.log('✅ Cloud veritabanına bağlandı');
    
    // 1. Kategorileri aktar
    console.log('\n🏷️ Kategoriler aktarılıyor...');
    const categories = await localClient.query('SELECT * FROM categories ORDER BY id');
    
    for (const category of categories.rows) {
      try {
        await cloudClient.query(`
          INSERT INTO categories (id, name, description, image_url, is_active, sort_order, created_at, updated_at)
          VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
          ON CONFLICT (id) DO UPDATE SET
            name = EXCLUDED.name,
            description = EXCLUDED.description,
            image_url = EXCLUDED.image_url,
            is_active = EXCLUDED.is_active,
            sort_order = EXCLUDED.sort_order,
            updated_at = CURRENT_TIMESTAMP
        `, [
          category.id, category.name, category.description, 
          category.image_url, category.is_active, category.sort_order,
          category.created_at, category.updated_at
        ]);
        console.log(`  ✅ ${category.name} aktarıldı`);
      } catch (err) {
        console.log(`  ❌ ${category.name} hatası:`, err.message);
      }
    }
    
    // 2. Ürünleri aktar
    console.log('\n🛍️ Ürünler aktarılıyor...');
    const products = await localClient.query('SELECT * FROM products ORDER BY id');
    
    for (const product of products.rows) {
      try {
        await cloudClient.query(`
          INSERT INTO products (id, name, description, price, category_id, image_url, is_available, created_at, updated_at)
          VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
          ON CONFLICT (id) DO UPDATE SET
            name = EXCLUDED.name,
            description = EXCLUDED.description,
            price = EXCLUDED.price,
            category_id = EXCLUDED.category_id,
            image_url = EXCLUDED.image_url,
            is_available = EXCLUDED.is_available,
            updated_at = CURRENT_TIMESTAMP
        `, [
          product.id, product.name, product.description, product.price,
          product.category_id, product.image_url, product.is_available,
          product.created_at, product.updated_at
        ]);
        console.log(`  ✅ ${product.name} (${product.price} TL) aktarıldı`);
      } catch (err) {
        console.log(`  ❌ ${product.name} hatası:`, err.message);
      }
    }
    
    // 3. Şubeleri aktar
    console.log('\n🏪 Şubeler aktarılıyor...');
    const branches = await localClient.query('SELECT * FROM branches ORDER BY id');
    
    for (const branch of branches.rows) {
      try {
        await cloudClient.query(`
          INSERT INTO branches (id, name, address, location, phone, email, working_hours, is_active, latitude, longitude, created_at, updated_at)
          VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12)
          ON CONFLICT (id) DO UPDATE SET
            name = EXCLUDED.name,
            address = EXCLUDED.address,
            location = EXCLUDED.location,
            phone = EXCLUDED.phone,
            email = EXCLUDED.email,
            working_hours = EXCLUDED.working_hours,
            is_active = EXCLUDED.is_active,
            latitude = EXCLUDED.latitude,
            longitude = EXCLUDED.longitude,
            updated_at = CURRENT_TIMESTAMP
        `, [
          branch.id, branch.name, branch.address, branch.location,
          branch.phone, branch.email, branch.working_hours, branch.is_active,
          branch.latitude, branch.longitude, branch.created_at, branch.updated_at
        ]);
        console.log(`  ✅ ${branch.name} aktarıldı`);
      } catch (err) {
        console.log(`  ❌ ${branch.name} hatası:`, err.message);
      }
    }
    
    // 4. Kampanyaları aktar
    console.log('\n🎯 Kampanyalar aktarılıyor...');
    const campaigns = await localClient.query('SELECT * FROM campaigns ORDER BY id');
    
    for (const campaign of campaigns.rows) {
      try {
        await cloudClient.query(`
          INSERT INTO campaigns (id, title, description, start_date, end_date, discount, image_url, is_active, created_at, updated_at)
          VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
          ON CONFLICT (id) DO UPDATE SET
            title = EXCLUDED.title,
            description = EXCLUDED.description,
            start_date = EXCLUDED.start_date,
            end_date = EXCLUDED.end_date,
            discount = EXCLUDED.discount,
            image_url = EXCLUDED.image_url,
            is_active = EXCLUDED.is_active,
            updated_at = CURRENT_TIMESTAMP
        `, [
          campaign.id, campaign.title, campaign.description, campaign.start_date,
          campaign.end_date, campaign.discount, campaign.image_url, campaign.is_active,
          campaign.created_at, campaign.updated_at
        ]);
        console.log(`  ✅ ${campaign.title} aktarıldı`);
      } catch (err) {
        console.log(`  ❌ ${campaign.title} hatası:`, err.message);
      }
    }
    
    // Son durumu kontrol et
    console.log('\n📊 Cloud veritabanı durumu:');
    
    const cloudCategories = await cloudClient.query('SELECT COUNT(*) as count FROM categories');
    const cloudProducts = await cloudClient.query('SELECT COUNT(*) as count FROM products');
    const cloudBranches = await cloudClient.query('SELECT COUNT(*) as count FROM branches');
    const cloudCampaigns = await cloudClient.query('SELECT COUNT(*) as count FROM campaigns');
    
    console.log(`  - Kategoriler: ${cloudCategories.rows[0].count}`);
    console.log(`  - Ürünler: ${cloudProducts.rows[0].count}`);
    console.log(`  - Şubeler: ${cloudBranches.rows[0].count}`);
    console.log(`  - Kampanyalar: ${cloudCampaigns.rows[0].count}`);
    
    console.log('\n🎉 Veri migrasyonu tamamlandı!');
    console.log('🌐 Artık Vercel API\'si cloud veritabanından veri çekecek');
    
    localClient.release();
    cloudClient.release();
    
  } catch (err) {
    console.error('❌ Migrasyon hatası:', err.message);
  } finally {
    await localPool.end();
    await cloudPool.end();
  }
}

migrateToCloud();
