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

Asagidaki goruntuler `resimler/` klasorundedir. Hepsi ayni goruntu genisliginde (210 px) olacak sekilde ayarlanmistir; tablo kullanilmamistir.

### Tanitim (onboarding)

<p align="center">
  <img width="210" alt="Tanitim 1" src="resimler/giris1.png" />
  <img width="210" alt="Tanitim 2" src="resimler/giris2.png" />
  <img width="210" alt="Tanitim 3" src="resimler/giris3.png" />
  <img width="210" alt="Tanitim 4" src="resimler/giris4.png" />
</p>

### Giris ve kayit

<p align="center">
  <img width="210" alt="Giris yap" src="resimler/giris_yap.png" />
  <img width="210" alt="Kayit ol" src="resimler/kayit_ol.png" />
</p>

### Ana ekran, buzdolabi ve tarama

<p align="center">
  <img width="210" alt="Ana ekran" src="resimler/ana_ekran.png" />
  <img width="210" alt="Buzdolabim" src="resimler/buzdolabim1.png" />
  <img width="210" alt="Buzdolabim detay" src="resimler/buzdolabim2.png" />
</p>

<p align="center">
  <img width="210" alt="Urun tara" src="resimler/tara.png" />
  <img width="210" alt="Yeni urun ekle" src="resimler/yeni_urun_ekle.png" />
  <img width="210" alt="Alisveris listesi" src="resimler/alisveris_listesi.png" />
  <img width="210" alt="Planla" src="resimler/planla.png" />
</p>

### Tarifler

<p align="center">
  <img width="210" alt="Tarifler" src="resimler/tarifler.png" />
  <img width="210" alt="Tarif detay 1" src="resimler/tarif1.png" />
  <img width="210" alt="Tarif detay 2" src="resimler/tarif2.png" />
</p>

### Profil, bildirimler ve ayarlar

<p align="center">
  <img width="210" alt="Profil" src="resimler/profil.png" />
  <img width="210" alt="Bildirimler" src="resimler/bildirimler.png" />
  <img width="210" alt="Ayarlar" src="resimler/ayarlar.png" />
</p>

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
