const axios = require('axios');

axios.post('http://localhost:3001/api/categories', {
  name: 'Test Kategori',
  description: 'Açıklama',
  image_url: 'http://test.com/img.png',
  is_active: true
})
.then(res => {
  console.log('Başarılı:', res.data);
})
.catch(err => {
  if (err.response) {
    console.error('API Hatası:', err.response.data);
  } else {
    console.error('İstek Hatası:', err.message);
  }
}); 