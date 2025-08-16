import { query } from '../config/database';

interface ExtractedData {
  categories: any[];
  products: any[];
  campaigns: any[];
  notifications: any[];
  sliderItems: any[];
  faqs: any[];
  branches: any[];
}

async function extractData(): Promise<ExtractedData> {
  try {
    const categories = await query('SELECT * FROM categories');
    const products = await query('SELECT * FROM products');
    const campaigns = await query('SELECT * FROM campaigns');
    const notifications = await query('SELECT * FROM notifications');
    const sliderItems = await query('SELECT * FROM slider_items');
    const faqs = await query('SELECT * FROM faqs');
    const branches = await query('SELECT * FROM branches');

    return {
      categories: categories.rows,
      products: products.rows,
      campaigns: campaigns.rows,
      notifications: notifications.rows,
      sliderItems: sliderItems.rows,
      faqs: faqs.rows,
      branches: branches.rows
    };
  } catch (error) {
    console.error('Error extracting data:', error);
    throw error;
  }
}

export default extractData; 