# Ngrok URL Güncelleme Script'i
# Bu script ngrok URL'sini otomatik olarak Flutter config'e ekler

Write-Host "🚀 Ngrok URL Güncelleme Script'i Başlatılıyor..." -ForegroundColor Green

# Ngrok'u başlat
Write-Host "📡 Ngrok başlatılıyor..." -ForegroundColor Yellow
Start-Process -NoNewWindow "C:\ngrok\ngrok.exe" -ArgumentList "http 3001"

# 5 saniye bekle
Start-Sleep -Seconds 5

# Ngrok URL'sini al
Write-Host "🔍 Ngrok URL'si aranıyor..." -ForegroundColor Yellow
try {
    $ngrokResponse = Invoke-RestMethod -Uri "http://localhost:4040/api/tunnels" -Method Get
    $ngrokUrl = $ngrokResponse.tunnels[0].public_url
    
    if ($ngrokUrl) {
        Write-Host "✅ Ngrok URL bulundu: $ngrokUrl" -ForegroundColor Green
        
        # Flutter config dosyasını güncelle
        $configPath = "mobile\lib\config\api_config.dart"
        
        if (Test-Path $configPath) {
            $content = Get-Content $configPath -Raw
            
            # URL'yi güncelle
            $newContent = $content -replace 'https://[a-zA-Z0-9\-]+\.ngrok-free\.app', $ngrokUrl
            
            Set-Content $configPath $newContent -Encoding UTF8
            
            Write-Host "✅ Flutter config güncellendi!" -ForegroundColor Green
            Write-Host "📱 Yeni API URL: $ngrokUrl/api" -ForegroundColor Cyan
            Write-Host "🔄 Flutter uygulamasını yeniden başlatın" -ForegroundColor Yellow
        } else {
            Write-Host "❌ Flutter config dosyası bulunamadı: $configPath" -ForegroundColor Red
        }
    } else {
        Write-Host "❌ Ngrok URL bulunamadı" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Hata: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "💡 Ngrok'un çalıştığından emin olun" -ForegroundColor Yellow
}

Write-Host "🎯 Script tamamlandı!" -ForegroundColor Green
