const express = require('express');
const cors = require('cors');

const app = express();

app.use(cors());
app.use(express.json());

// Test endpoint - bu kesin çalışacak
app.get('/api/test', (req, res) => {
  res.json({ 
    message: 'Server is running!',
    timestamp: new Date().toISOString(),
    status: 'OK'
  });
});

// Health endpoint
app.get('/api/health', (req, res) => {
  res.json({ 
    status: 'OK', 
    message: 'Bonavias API Server çalışıyor!',
    timestamp: new Date().toISOString()
  });
});

// Campaigns endpoint - Flutter app için gerekli
app.get('/api/campaigns', (req, res) => {
  // Şimdilik test verisi döndürelim
  res.json([
    {
      id: 1,
      title: "Test Kampanya",
      description: "Bu bir test kampanyasıdır",
      image_url: "https://via.placeholder.com/300x200",
      is_active: true,
      created_at: new Date().toISOString()
    }
  ]);
});

// Active campaigns endpoint
app.get('/api/campaigns/active', (req, res) => {
  res.json([
    {
      id: 1,
      title: "Aktif Kampanya",
      description: "Bu aktif bir kampanyadır",
      image_url: "https://via.placeholder.com/300x200",
      is_active: true,
      created_at: new Date().toISOString()
    }
  ]);
});

// Products endpoint - Flutter app için gerekli
app.get('/api/products', (req, res) => {
  res.json([
    {
      id: 1,
      name: "Test Ürün",
      description: "Bu bir test ürünüdür",
      price: 25.99,
      image_url: "https://via.placeholder.com/300x200",
      category_id: 1,
      is_available: true
    }
  ]);
});

// Categories endpoint
app.get('/api/categories', (req, res) => {
  res.json([
    {
      id: 1,
      name: "Test Kategori",
      description: "Bu bir test kategorisidir",
      image_url: "https://via.placeholder.com/300x200",
      sort_order: 1
    }
  ]);
});

// Sliders endpoint
app.get('/api/sliders', (req, res) => {
  res.json([
    {
      id: 1,
      title: "Test Slider",
      image_url: "https://via.placeholder.com/400x200",
      sort_order: 1
    }
  ]);
});

// Stories endpoint
app.get('/api/stories', (req, res) => {
  res.json([
    {
      id: 1,
      title: "Test Hikaye",
      content: "Bu bir test hikayesidir",
      image_url: "https://via.placeholder.com/300x300",
      created_at: new Date().toISOString()
    }
  ]);
});

// Branches endpoint
app.get('/api/branches', (req, res) => {
  res.json([
    {
      id: 1,
      name: "Test Şube",
      address: "Test Adres",
      phone: "555-1234",
      latitude: 41.0082,
      longitude: 28.9784
    }
  ]);
});

// Root endpoint
app.get('/', (req, res) => {
  res.json({ 
    message: 'Bonavias API Server',
    status: 'running',
    endpoints: [
      '/api/health', 
      '/api/test', 
      '/api/campaigns', 
      '/api/campaigns/active',
      '/api/products', 
      '/api/categories', 
      '/api/sliders', 
      '/api/stories', 
      '/api/branches'
    ]
  });
});

// Export for Vercel
module.exports = app;
