const express = require('express');
const cors = require('cors');

const app = express();

app.use(cors());
app.use(express.json());

// ngrok proxy server URL'i - Environment variable'dan al
const NGROK_URL = process.env.NGROK_URL || 'https://b88f9db58b94.ngrok-free.app';

// HTTP client için axios kullanacağız
const axios = require('axios');

// Test endpoint - bu kesin çalışacak
app.get('/api/test', (req, res) => {
  res.json({ 
    message: 'Server is running!',
    timestamp: new Date().toISOString(),
    status: 'OK'
  });
});

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

// Campaigns endpoint - ngrok proxy server'dan veri
app.get('/api/campaigns', async (req, res) => {
  try {
    const response = await axios.get(`${NGROK_URL}/api/campaigns`);
    res.json(response.data);
  } catch (err) {
    console.error('❌ Campaigns hatası:', err.message);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Active campaigns endpoint - ngrok proxy server'dan veri
app.get('/api/campaigns/active', async (req, res) => {
  try {
    const response = await axios.get(`${NGROK_URL}/api/campaigns/active`);
    res.json(response.data);
  } catch (err) {
    console.error('❌ Active campaigns hatası:', err.message);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Products endpoint - ngrok proxy server'dan veri
app.get('/api/products', async (req, res) => {
  try {
    const response = await axios.get(`${NGROK_URL}/api/products`);
    res.json(response.data);
  } catch (err) {
    console.error('❌ Products hatası:', err.message);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Categories endpoint - ngrok proxy server'dan veri
app.get('/api/categories', async (req, res) => {
  try {
    const response = await axios.get(`${NGROK_URL}/api/categories`);
    res.json(response.data);
  } catch (err) {
    console.error('❌ Categories hatası:', err.message);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Sliders endpoint - ngrok proxy server'dan veri
app.get('/api/sliders', async (req, res) => {
  try {
    const response = await axios.get(`${NGROK_URL}/api/sliders`);
    res.json(response.data);
  } catch (err) {
    console.error('❌ Sliders hatası:', err.message);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Stories endpoint - ngrok proxy server'dan veri
app.get('/api/stories', async (req, res) => {
  try {
    const response = await axios.get(`${NGROK_URL}/api/stories`);
    res.json(response.data);
  } catch (err) {
    console.error('❌ Stories hatası:', err.message);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Branches endpoint - ngrok proxy server'dan veri
app.get('/api/branches', async (req, res) => {
  try {
    const response = await axios.get(`${NGROK_URL}/api/branches`);
    res.json(response.data);
  } catch (err) {
    console.error('❌ Branches hatası:', err.message);
  }
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
