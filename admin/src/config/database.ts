import { Pool } from 'pg';

console.log('DB Connection:', process.env.DATABASE_URL || 'postgresql://postgres.wljqsddspfwobbuunqyn:bonavias2002@aws-0-eu-central-1.pooler.supabase.com:6543/postgres');

const pool = new Pool({
  connectionString: process.env.DATABASE_URL || 'postgresql://postgres.wljqsddspfwobbuunqyn:bonavias2002@aws-0-eu-central-1.pooler.supabase.com:6543/postgres',
  ssl: { rejectUnauthorized: false },
});

export const query = async (text: string, params?: any[]) => {
  try {
    const result = await pool.query(text, params);
    return result;
  } catch (error) {
    console.error('Database query error:', error);
    throw error;
  }
};

export default pool; 