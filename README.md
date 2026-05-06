# Mutfak Asistanim

**Mutfak Asistanim**, evdeki gida urunlerini duzenli sekilde takip etmeyi, son kullanma tarihlerini goz onunde bulundurmayi ve eldeki malzemelere uygun tariflerle planli tuketimi desteklemeyi amaclayan bir mutfak asistanidir. Uygulama; buzdolabi envanteri, alisveris listesi, bildirimler, tarif kesfi ve yapay zeka destekli urun tarama gibi ozelliklerle israfi azaltmaya ve gunluk mutfak rutinini sadelestirmeye odaklanir.

Proje **dort kisilik bir ekip** tarafindan gelistirilmistir:

- Ayşe Arpacı
- Elif Kavurga
- Edanur Ayıbasan
- Uğur Nusretoğlu

---

## Kullanilan teknolojiler

### Mobil ve istemci (Flutter)

- **Flutter** (Dart SDK ^3.11), Material tasarim
- **HTTP** ile REST API iletisimi
- **Google ML Kit Text Recognition** — etiket / metin okuma
- **TensorFlow Lite** (`tflite_flutter`) — cihaz uzerinde urun tarama ve oneri akisi
- **Camera**, **image_picker**, **image** — kamera ve goruntu isleme
- **mobile_scanner** — barkod / QR tarama
- **Open Food Facts** entegrasyonu (urun bilgisi servisi)

### Sunucu (Spring Boot)

- **Java 17**, **Spring Boot 4** (Maven)
- **Spring Web MVC**, **Spring Data JPA**, **Spring Security**
- **PostgreSQL** (uretim / Railway), **H2** (gelistirme)
- **JWT** (jjwt) — kimlik dogrulama ve oturum yonetimi
- **Lombok**

### Altyapi

- **Railway** uzerinde ornek kurulum: ayri backend ve Flutter web servisleri, PostgreSQL; istemci tarafinda `BACKEND_URL` ile API erisimi (ayrintilar asagida).

---

## Uygulama goruntuleri

Asagidaki goruntuler `resimler/` klasorundeki ekran goruntuleridir.

### Tanitim (onboarding)

Splash sonrasi kullaniciyi karsilayan tanitim adimlari:

| | |
| --- | --- |
| ![Tanitim 1](resimler/giris1.png) | ![Tanitim 2](resimler/giris2.png) |
| ![Tanitim 3](resimler/giris3.png) | ![Tanitim 4](resimler/giris4.png) |

### Giris ve kayit

| Giris yap | Kayit ol |
| --- | --- |
| ![Giris yap](resimler/giris_yap.png) | ![Kayit ol](resimler/kayit_ol.png) |

### Ana akis

| Ana ekran | Buzdolabim | Buzdolabim (detay) |
| --- | --- | --- |
| ![Ana ekran](resimler/ana_ekran.png) | ![Buzdolabim](resimler/buzdolabim1.png) | ![Buzdolabim 2](resimler/buzdolabim2.png) |

| Urun tara | Yeni urun ekle |
| --- | --- |
| ![Urun tara](resimler/tara.png) | ![Yeni urun ekle](resimler/yeni_urun_ekle.png) |

| Alisveris listesi | Planla |
| --- | --- |
| ![Alisveris listesi](resimler/alisveris_listesi.png) | ![Planla](resimler/planla.png) |

### Tarifler

| Tarif listesi | Tarif detay 1 | Tarif detay 2 |
| --- | --- | --- |
| ![Tarifler](resimler/tarifler.png) | ![Tarif 1](resimler/tarif1.png) | ![Tarif 2](resimler/tarif2.png) |

### Profil, bildirimler ve ayarlar

| Profil / istatistik | Bildirimler | Ayarlar |
| --- | --- | --- |
| ![Profil](resimler/profil.png) | ![Bildirimler](resimler/bildirimler.png) | ![Ayarlar](resimler/ayarlar.png) |

---

## Depo yapisi

| Klasor | Aciklama |
| --- | --- |
| `mutfak_asistanim/` | Flutter uygulamasi (Android, iOS, web vb.) |
| `backend/` | Spring Boot REST API |
| `resimler/` | README ve sunumlar icin ekran goruntuleri |

---

## Yerel calistirma (kisaca)

**Backend:** `backend` dizininde Maven ile Spring Boot uygulamasini baslatin; `application.properties` icinde veritabani ayarlarini kullanin.

**Flutter:** `mutfak_asistanim` dizininde:

```bash
flutter pub get
flutter run
```

Mobil veya fiziksel cihazda API adresini vermek icin:

```bash
flutter run --dart-define=API_BASE_URL=https://<backend-public-domain>
```

---

## Railway dagitimi (ozet)

- **Backend servisi:** Root Directory `backend`, degiskenler: `JWT_SECRET`, PostgreSQL baglanti bilgileri (`PGHOST`, `PGPORT`, vb.). Saglik kontrolu: `/health`.
- **Frontend servisi:** Root Directory `mutfak_asistanim`, `BACKEND_URL=http://${{backend.RAILWAY_PRIVATE_DOMAIN}}` (servis adi Railway’deki backend adiyla ayni olmali). Saglik kontrolu: `/health`.
- Veritabani: PostgreSQL; backend sirasiyla `DB_URL` / `SPRING_DATASOURCE_URL` / `PG*` degiskenlerini okuyacak sekilde yapilandirilmistir.
