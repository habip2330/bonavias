const { Pool } = require('pg');

const pool = new Pool({
  user: 'postgres',
  host: 'localhost',
  database: 'bonavias',
  password: 'Habip2330@1',
  port: 5432,
});

async function checkProducts() {
  try {
    const result = await pool.query('SELECT id, name FROM products LIMIT 5');
    console.log('Ürünler:');
    result.rows.forEach(row => {
      console.log(`ID: ${row.id}, İsim: ${row.name}`);
    });
  } catch (err) {
    console.error('Hata:', err);
  } finally {
    await pool.end();
  }
}

checkProducts(); 