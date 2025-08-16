const { Pool } = require('pg');

// PostgreSQL bağlantı ayarları
const pool = new Pool({
  user: 'postgres',
  host: 'localhost',
  database: 'bonavias',
  password: 'Habip2330@1',
  port: 5432,
});

async function updateProductIngredients() {
  try {
    console.log('Ürünlere ingredients verisi ekleniyor...');
    
    // Önce mevcut ürünleri al
    const products = await pool.query('SELECT id, name FROM products LIMIT 5');
    console.log('Mevcut ürünler:');
    products.rows.forEach(row => {
      console.log(`- ${row.name} (${row.id})`);
    });
    
    console.log('\nIngredients güncelleniyor...');
    
    // Pancake Bona
    await pool.query('UPDATE products SET ingredients = $1 WHERE id = $2', 
      [JSON.stringify(['gluten', 'milk', 'egg']), 'f5fe8d1b-177f-4223-898c-51981b6b2f4a']
    );
    console.log('✅ Pancake Bona güncellendi: gluten, milk, egg');
    
    // Pancake Babs
    await pool.query('UPDATE products SET ingredients = $1 WHERE id = $2', 
      [JSON.stringify(['nuts', 'milk', 'soy']), '76c7b3f6-f7a2-4430-b0dd-5aa8e8d774a4']
    );
    console.log('✅ Pancake Babs güncellendi: nuts, milk, soy');
    
    // Pancake Fondue
    await pool.query('UPDATE products SET ingredients = $1 WHERE id = $2', 
      [JSON.stringify(['gluten', 'milk', 'egg', 'nuts']), '7d6d3e3d-3153-4d6c-8557-0a93e95fe657']
    );
    console.log('✅ Pancake Fondue güncellendi: gluten, milk, egg, nuts');
    
    // Pancake Lovers
    await pool.query('UPDATE products SET ingredients = $1 WHERE id = $2', 
      [JSON.stringify(['gluten', 'egg', 'milk']), '938e383f-7128-4d26-9d4a-54feee0637bf']
    );
    console.log('✅ Pancake Lovers güncellendi: gluten, egg, milk');
    
    // A-Love BOX Mini
    await pool.query('UPDATE products SET ingredients = $1 WHERE id = $2', 
      [JSON.stringify(['milk', 'nuts']), '2f074db4-6072-4c26-8caf-cd20d7b37ded']
    );
    console.log('✅ A-Love BOX Mini güncellendi: milk, nuts');
    
    // Kontrol et
    const result = await pool.query('SELECT id, name, ingredients FROM products WHERE ingredients IS NOT NULL LIMIT 5');
    console.log('\n📋 Güncellenmiş ürünler:');
    result.rows.forEach(row => {
      try {
        let ingredients = [];
        if (typeof row.ingredients === 'string') {
          try {
            ingredients = JSON.parse(row.ingredients);
          } catch (e) {
            // String olarak saklanmışsa virgülle ayır
            ingredients = row.ingredients.split(',').map(s => s.trim());
          }
        } else if (Array.isArray(row.ingredients)) {
          ingredients = row.ingredients;
        }
        console.log(`- ${row.name}: ${ingredients.join(', ')}`);
      } catch (e) {
        console.log(`- ${row.name}: [Parse hatası]`);
      }
    });
    
    console.log('\n🎉 İçerikler başarıyla güncellendi!');
  } catch (err) {
    console.error('❌ Güncelleme hatası:', err);
  } finally {
    await pool.end();
  }
}

updateProductIngredients(); 