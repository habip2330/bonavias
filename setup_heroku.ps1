# Heroku Kurulum ve Deployment Script'i
# Bu script Heroku'da PostgreSQL ile test sistemi kurar

Write-Host "🚀 Heroku Kurulum Script'i Başlatılıyor..." -ForegroundColor Green

# Heroku CLI kontrolü
Write-Host "🔍 Heroku CLI kontrol ediliyor..." -ForegroundColor Yellow
try {
    $herokuVersion = heroku --version
    Write-Host "✅ Heroku CLI mevcut: $herokuVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Heroku CLI bulunamadı!" -ForegroundColor Red
    Write-Host "📥 Lütfen önce Heroku CLI'yi kurun:" -ForegroundColor Yellow
    Write-Host "   https://devcenter.heroku.com/articles/heroku-cli" -ForegroundColor Cyan
    exit 1
}

# Heroku login kontrolü
Write-Host "🔐 Heroku login kontrol ediliyor..." -ForegroundColor Yellow
try {
    $whoami = heroku auth:whoami
    Write-Host "✅ Heroku'da giriş yapılmış: $whoami" -ForegroundColor Green
} catch {
    Write-Host "🔑 Heroku'da giriş yapmanız gerekiyor..." -ForegroundColor Yellow
    Write-Host "💡 Komut: heroku login" -ForegroundColor Cyan
    exit 1
}

# Heroku app oluştur
Write-Host "🏗️ Heroku app oluşturuluyor..." -ForegroundColor Yellow
$appName = "bonavias-api-" + (Get-Random -Minimum 1000 -Maximum 9999)
Write-Host "📱 App adı: $appName" -ForegroundColor Cyan

try {
    heroku create $appName
    Write-Host "✅ Heroku app oluşturuldu: $appName" -ForegroundColor Green
} catch {
    Write-Host "❌ App oluşturma hatası" -ForegroundColor Red
    exit 1
}

# PostgreSQL addon ekle
Write-Host "🗄️ PostgreSQL addon ekleniyor..." -ForegroundColor Yellow
try {
    heroku addons:create heroku-postgresql:mini --app $appName
    Write-Host "✅ PostgreSQL addon eklendi" -ForegroundColor Green
} catch {
    Write-Host "❌ PostgreSQL addon hatası" -ForegroundColor Red
    exit 1
}

# Environment variables ayarla
Write-Host "⚙️ Environment variables ayarlanıyor..." -ForegroundColor Yellow
try {
    heroku config:set NODE_ENV=production --app $appName
    Write-Host "✅ NODE_ENV ayarlandı" -ForegroundColor Green
} catch {
    Write-Host "❌ Environment variable hatası" -ForegroundColor Red
}

# Database URL'yi al
Write-Host "🔗 Database URL alınıyor..." -ForegroundColor Yellow
try {
    $dbUrl = heroku config:get DATABASE_URL --app $appName
    Write-Host "✅ Database URL: $dbUrl" -ForegroundColor Green
} catch {
    Write-Host "❌ Database URL hatası" -ForegroundColor Red
}

# Flutter config güncelle
Write-Host "📱 Flutter config güncelleniyor..." -ForegroundColor Yellow
$configPath = "..\mobile\lib\config\api_config.dart"
$herokuUrl = "https://$appName.herokuapp.com"

if (Test-Path $configPath) {
    $content = Get-Content $configPath -Raw
    
    # Test URL'yi güncelle
    $newContent = $content -replace 'https://test\.your-domain\.com', $herokuUrl
    
    Set-Content $configPath $newContent -Encoding UTF8
    
    Write-Host "✅ Flutter config güncellendi!" -ForegroundColor Green
    Write-Host "🌐 Yeni API URL: $herokuUrl/api" -ForegroundColor Cyan
} else {
    Write-Host "❌ Flutter config dosyası bulunamadı" -ForegroundColor Red
}

Write-Host "🎯 Heroku kurulum tamamlandı!" -ForegroundColor Green
Write-Host "📋 Sonraki adımlar:" -ForegroundColor Yellow
Write-Host "1. git add ." -ForegroundColor Cyan
Write-Host "2. git commit -m 'Heroku deployment'" -ForegroundColor Cyan
Write-Host "3. git push heroku main" -ForegroundColor Cyan
Write-Host "4. heroku open --app $appName" -ForegroundColor Cyan
