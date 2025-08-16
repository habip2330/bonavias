# cPanel'e Backend API Yükleme Talimatları

## 1. cPanel'e Giriş
- `habipbahceci.com/cpanel` adresine gidin
- Kullanıcı adı ve şifrenizle giriş yapın

## 2. File Manager'ı Açın
- **Files** bölümünde **File Manager** tıklayın
- **public_html** klasörüne gidin

## 3. Backend Klasörü Oluşturun
- **public_html** içinde **api** adında yeni klasör oluşturun
- Bu klasörün tam yolu: `public_html/api/` olacak

## 4. Gerekli Dosyaları Yükleyin
Şu dosyaları **api** klasörüne yükleyin:

### Ana Dosyalar:
- `server.js` → `api/index.js` olarak yeniden adlandırın
- `package.json`
- `package-lock.json`

### Klasörler:
- `database/` → `api/database/`
- `src/` → `api/src/`
- `public/` → `api/public/`
- `uploads/` → `api/uploads/`

## 5. package.json'u Güncelleyin
`api/package.json` dosyasında şu değişiklikleri yapın:

```json
{
  "name": "bonavias-api",
  "version": "1.0.0",
  "main": "index.js",
  "scripts": {
    "start": "node index.js",
    "dev": "nodemon index.js"
  },
  "dependencies": {
    "express": "^4.18.2",
    "cors": "^2.8.5",
    "pg": "^8.11.3",
    "multer": "^1.4.5-lts.1",
    "bcryptjs": "^2.4.3",
    "jsonwebtoken": "^9.0.2"
  }
}
```

## 6. server.js'i index.js Olarak Yeniden Adlandırın
- `server.js` dosyasını `index.js` olarak yeniden adlandırın
- Port numarasını 3001'den 80'e değiştirin (cPanel'de 80 portu kullanılır)

## 7. Database Bağlantısını Güncelleyin
cPanel'de MySQL database oluşturun ve bağlantı bilgilerini güncelleyin.

## 8. Node.js Uygulamasını Başlatın
cPanel'de **Setup Node.js App** bölümünde:
- App name: `bonavias-api`
- Node.js version: `18.x` veya `20.x`
- App root: `public_html/api`
- App URL: `habipbahceci.com/api`
- Entry point: `index.js`

## 9. Test Edin
Tarayıcıda `https://habipbahceci.com/api/categories` adresini ziyaret edin.

## 10. Flutter Uygulamasını Test Edin
Şimdi Flutter uygulaması `https://habipbahceci.com/api` endpoint'ini kullanacak.
