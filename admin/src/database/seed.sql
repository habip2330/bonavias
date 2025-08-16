-- Insert Categories
INSERT INTO categories (name, description, image_url, is_active) VALUES
('Hot Drinks', 'Warm beverages including coffee and tea', 'https://placehold.co/200x200', true),
('Cold Drinks', 'Refreshing cold beverages', 'https://placehold.co/200x200', true);

-- Insert Products
INSERT INTO products (name, description, price, category_id, image_url, is_available) VALUES
('Cappuccino', 'Classic Italian coffee with steamed milk foam', 4.50, 
    (SELECT id FROM categories WHERE name = 'Hot Drinks'),
    'https://placehold.co/200x200', true);

-- Insert Campaigns
INSERT INTO campaigns (title, description, start_date, end_date, discount, image_url, is_active) VALUES
('Summer Special', 'Get 20% off on all cold drinks', CURRENT_DATE, 
    CURRENT_DATE + INTERVAL '30 days', 20, 
    'https://placehold.co/200x200', true);

-- Insert Notifications
INSERT INTO notifications (title, message, type, is_read) VALUES
('New Menu Items', 'Check out our new summer drinks collection!', 'info', false);

-- Insert Slider Items
INSERT INTO slider_items (title, description, image_url, link, display_order, is_active) VALUES
('Summer Collection', 'Discover our refreshing summer drinks', 
    'https://placehold.co/1200x400', '/menu', 1, true);

-- Insert FAQ Categories
INSERT INTO faq_categories (name) VALUES
('General'),
('Orders'),
('Menu'),
('Delivery'),
('Payment');

-- Insert FAQs
INSERT INTO faqs (question, answer, category_id, display_order, is_active) VALUES
('What are your opening hours?', 'We are open from 8:00 AM to 10:00 PM every day.',
    (SELECT id FROM faq_categories WHERE name = 'General'), 1, true);

-- Insert Branches
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
); 