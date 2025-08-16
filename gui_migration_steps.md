# GUI ile Veritabanı Güncelleme Adımları

## pgAdmin ile:

### 1. Tablo Yapısını Güncelle
- pgAdmin'de veritabanınızı açın
- Tables > branches > sağ tık > Properties
- Columns sekmesine gidin
- "Add Column" butonuna tıklayın

### 2. Yeni Kolonlar Ekle:

**Location Kolonu:**
- Name: `location`
- Data type: `text`
- Not NULL: ❌ (işaretlemeyin)

**Working Hours Kolonu:**
- Name: `working_hours`  
- Data type: `jsonb`
- Not NULL: ❌ (işaretlemeyin)

### 3. Opening Hours'u Güncelle:
- `opening_hours` kolonuna sağ tık > Properties
- Not NULL işaretini kaldırın

### 4. SQL Query'leri Çalıştır:
- Tools > Query Tool
- Aşağıdaki kodu yapıştırın ve çalıştırın:

```sql
-- Varsayılan çalışma saatleri
UPDATE branches 
SET working_hours = '{
    "monday": {"day": "Pazartesi", "isOpen": true, "openTime": "09:00", "closeTime": "22:00"},
    "tuesday": {"day": "Salı", "isOpen": true, "openTime": "09:00", "closeTime": "22:00"},
    "wednesday": {"day": "Çarşamba", "isOpen": true, "openTime": "09:00", "closeTime": "22:00"},
    "thursday": {"day": "Perşembe", "isOpen": true, "openTime": "09:00", "closeTime": "22:00"},
    "friday": {"day": "Cuma", "isOpen": true, "openTime": "09:00", "closeTime": "22:00"},
    "saturday": {"day": "Cumartesi", "isOpen": true, "openTime": "09:00", "closeTime": "22:00"},
    "sunday": {"day": "Pazar", "isOpen": true, "openTime": "09:00", "closeTime": "22:00"}
}'::JSONB
WHERE working_hours IS NULL;

-- Location alanını doldur
UPDATE branches SET location = address WHERE location IS NULL;
```

## Kontrol:
```sql
SELECT * FROM branches LIMIT 3;
```

✅ **Başarı!** Artık admin panelde günlük çalışma saatleri düzenleyebilirsiniz. 