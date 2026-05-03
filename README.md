# Mutfak-Asistanim

Yapay zeka destekli gida yonetimi ve israf azaltma uygulamasi.

## Mimari

- `backend/`: Spring Boot REST API
- `mutfak_asistanim/`: Flutter uygulamasi ve Railway icin web servisi

Railway uzerinde onerilen kurulum:

1. `backend` adinda bir servis
2. `frontend` adinda bir servis
3. Ayni project icinde bir PostgreSQL servisi

Frontend Railway uzerinde Flutter web build'ini sunar ve API isteklerini `BACKEND_URL` uzerinden backend servisine proxy eder. Boylece web tarafinda sabit API adresi ve CORS yonetimi daha sade hale gelir.

## Railway Kurulumu

### Backend servisi

- Root Directory: `/backend`
- Config Path: `/backend/railway.toml`

Tanimlanmasi gereken degiskenler:

- `JWT_SECRET`: Guclu bir Base64 secret
- `JWT_EXPIRATION_MS`: Istege bagli, varsayilan `7200000`
- `DB_SCHEMA`: Istege bagli, varsayilan `kitchen_assistant`
- `PGHOST`, `PGPORT`, `PGDATABASE`, `PGUSER`, `PGPASSWORD`:
  PostgreSQL servisinden reference variable olarak baglanmali

Istege bagli degiskenler:

- `APP_CORS_ALLOWED_ORIGIN_PATTERNS`
- `JPA_DDL_AUTO`
- `JPA_SHOW_SQL`

Healthcheck:

- `/health`

### Frontend servisi

- Root Directory: `/mutfak_asistanim`
- Config Path: `/mutfak_asistanim/railway.toml`

Tanimlanmasi gereken degisken:

- `BACKEND_URL=http://${{backend.RAILWAY_PRIVATE_DOMAIN}}`

Notlar:

- Buradaki `backend` reference adi, Railway uzerindeki backend servis adiyla ayni olmalidir.
- Istersen private domain yerine backend public domain de kullanabilirsin.

Healthcheck:

- `/health`

### Veritabani

Backend uygulamasi su sirayla baglanti bilgisi okuyacak sekilde hazirlandi:

1. `DB_URL`, `DB_USERNAME`, `DB_PASSWORD`
2. `SPRING_DATASOURCE_URL`
3. `PGHOST`, `PGPORT`, `PGDATABASE`, `PGUSER`, `PGPASSWORD`
4. Yerel fallback degerleri

## Mobil build notu

APK veya fiziksel cihaz build'lerinde backend public domain'i dogrudan verebilirsin:

```bash
flutter run --dart-define=API_BASE_URL=https://<backend-public-domain>
```
