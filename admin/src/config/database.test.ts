import { query } from './database';

const testDatabaseConnection = async () => {
  try {
    // Test categories
    const categories = await query('SELECT * FROM categories');
    console.log('Categories:', categories.rows);

    // Test products
    const products = await query('SELECT * FROM products');
    console.log('Products:', products.rows);

    // Test campaigns
    const campaigns = await query('SELECT * FROM campaigns');
    console.log('Campaigns:', campaigns.rows);

    // Test notifications
    const notifications = await query('SELECT * FROM notifications');
    console.log('Notifications:', notifications.rows);

    // Test slider items
    const sliderItems = await query('SELECT * FROM slider_items');
    console.log('Slider Items:', sliderItems.rows);

    // Test FAQ categories
    const faqCategories = await query('SELECT * FROM faq_categories');
    console.log('FAQ Categories:', faqCategories.rows);

    // Test FAQs
    const faqs = await query('SELECT * FROM faqs');
    console.log('FAQs:', faqs.rows);

    // Test branches
    const branches = await query('SELECT * FROM branches');
    console.log('Branches:', branches.rows);

    console.log('All database tests passed successfully!');
  } catch (error) {
    console.error('Database test failed:', error);
  }
};

testDatabaseConnection();

describe('Database', () => {
  it('should connect to the database', async () => {
    const result = await query('SELECT NOW()');
    expect(result.rows[0]).toBeDefined();
  });
}); 