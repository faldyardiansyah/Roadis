# 🛣️ ROADIS Mobile

### Road Damage Reporting & Intelligent Detection System

**ROADIS** adalah aplikasi mobile berbasis Flutter yang dirancang untuk membantu masyarakat melaporkan kerusakan jalan dengan memanfaatkan teknologi *Artificial Intelligence* (AI), GPS, dan Geographic Information System (GIS).

Aplikasi ini menggunakan model **YOLOv11s** untuk mendeteksi jenis kerusakan jalan dari gambar, sehingga membantu proses pelaporan menjadi lebih praktis, informatif, dan terstruktur.

> 📍 Detect road damage. Report with confidence. Build safer roads.

---

## ✨ Features

- 🔐 **Authentication** — Registrasi, login, dan pengelolaan sesi pengguna.
- 📸 **AI Road Damage Detection** — Mendeteksi kerusakan jalan menggunakan YOLOv11s dan TensorFlow Lite.
- 🧠 **Automatic Report Assistance** — Membantu mengisi informasi laporan berdasarkan hasil deteksi AI.
- 📍 **GPS Location** — Mengambil koordinat lokasi kerusakan jalan.
- 🗺️ **Interactive Map** — Menampilkan informasi lokasi laporan menggunakan OpenStreetMap.
- 📝 **Road Damage Reporting** — Membuat laporan dengan foto, deskripsi, jenis kerusakan, koordinat, dan wilayah.
- 📚 **Report History** — Melihat riwayat laporan dan status penanganannya.
- 👤 **Profile Management** — Mengelola informasi akun pengguna.
- 🔔 **Notifications** — Mendukung informasi terkait laporan dan pembaruan status.
- 💬 **Report-based Chat** — Mendukung komunikasi warga dan admin terkait laporan tertentu.

## 🧠 AI Detection

ROADIS mengintegrasikan model YOLOv11s yang dikonversi ke format TensorFlow Lite untuk mendukung inferensi langsung pada perangkat mobile yang kompatibel.

Model dirancang untuk mengenali tujuh kategori kerusakan jalan:

| No. | Class | Label Indonesia |
|---:|---|---|
| 1 | Alligator Cracking | Retak Buaya |
| 2 | Edge Cracking | Retak Tepi |
| 3 | Longitudinal Cracking | Retak Memanjang |
| 4 | Patching | Tambalan |
| 5 | Pothole | Lubang |
| 6 | Rutting | cekungan Jalan |
| 7 | Transverse Cracking | Retak Melintang |

Hasil deteksi dapat digunakan sebagai referensi untuk membantu pengguna menyusun laporan kerusakan jalan. Hasil AI tetap perlu diperiksa oleh pengguna sebelum laporan dikirimkan.

## 🛠️ Tech Stack

| Technology | Purpose |
|---|---|
| Flutter | Mobile application development |
| Dart | Main programming language |
| GetX | State management and navigation |
| TensorFlow Lite | On-device AI inference |
| YOLOv11s | Road damage detection model |
| GPS / Geolocator | Location acquisition |
| OpenStreetMap | Map data and visualization |
| REST API | Communication with backend |
| Go / Gin | Backend API |
| Database | Storage of users and reports |

## 🏗️ System Architecture

```text
┌────────────────────────────┐
│       ROADIS Mobile        │
│         Flutter            │
└─────────────┬──────────────┘
              │
      ┌───────┴────────┐
      │                │
      ▼                ▼
┌──────────────┐ ┌───────────────┐
│ YOLOv11s     │ │ GPS & Open-   │
│ TensorFlow   │ │ StreetMap     │
│ Lite         │ │               │
└──────┬───────┘ └───────┬───────┘
       │                 │
       └────────┬────────┘
                ▼
      ┌───────────────────┐
      │ Report Management  │
      │ Photo, Type, GPS   │
      └─────────┬─────────┘
                │ REST API
                ▼
      ┌───────────────────┐
      │ Go / Gin Backend  │
      └─────────┬─────────┘
                ▼
      ┌───────────────────┐
      │ Database & Admin  │
      └───────────────────┘
```

## 📱 Application Screens

Tambahkan screenshot aplikasi pada folder `screenshots/` agar pengunjung repository dapat melihat tampilan ROADIS.

| Home | Maps | AI Detection |
|---|---|---|
| Tambahkan screenshot Home | Tambahkan screenshot Maps | Tambahkan screenshot Camera |

| Report Form | History | Profile |
|---|---|---|
| Tambahkan screenshot Form | Tambahkan screenshot History | Tambahkan screenshot Profile |

## 🚀 Getting Started

### Prerequisites

Pastikan perangkat pengembangan sudah memiliki:

- Flutter SDK dan Dart SDK.
- Android Studio atau Visual Studio Code.
- Android SDK dan perangkat Android atau emulator.
- Backend ROADIS yang sudah berjalan.
- File model TensorFlow Lite yang diperlukan aplikasi.

### 1. Clone Repository

```bash
git clone https://github.com/faldyardiansyah/Roadis.git
cd roadis
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Configure API

Periksa konfigurasi API pada file:

```text
lib/core/api_config.dart
```

Sesuaikan base URL dengan alamat backend yang digunakan.

Contoh untuk perangkat Android fisik yang terhubung ke jaringan Wi-Fi yang sama dengan komputer:

```dart
static const String baseUrl = 'http://IP_KOMPUTER:8080/api';
```

Ganti `IP_KOMPUTER` dengan alamat IP lokal komputer yang menjalankan backend. Pastikan port, jaringan, firewall, dan konfigurasi backend sudah sesuai.

### 4. Configure AI Model

Pastikan model YOLOv11s TensorFlow Lite tersedia pada lokasi yang digunakan aplikasi:

```text
assets/
└── models/
    └── best.tflite
```

Periksa juga deklarasi aset pada `pubspec.yaml` dan pastikan konfigurasi preprocessing serta output model sesuai dengan hasil ekspor model.

### 5. Run Application

```bash
flutter run
```

Untuk memeriksa kode sebelum dijalankan:

```bash
flutter analyze
```

## 📂 Project Structure

Struktur utama project ROADIS Mobile:

```text
lib/
├── auth/
│   ├── controllers/
│   └── services/
├── core/
│   ├── api_config.dart
│   ├── detection/
│   │   ├── models/
│   │   └── services/
│   └── laporan/
│       └── models/
├── modules/
│   ├── camera/
│   │   └── screens/
│   ├── home/
│   │   └── screens/
│   ├── maps/
│   │   └── screens/
│   ├── history/
│   │   └── screens/
│   └── profile/
│       └── screens/
├── routes/
├── utils/
└── main.dart
```

Struktur di atas menggambarkan direktori utama yang digunakan. Modul tambahan, seperti form laporan dan fitur chat, dapat berada pada direktori tersendiri sesuai implementasi project.

## 🔒 Security & Privacy

- Endpoint API yang memerlukan autentikasi harus menggunakan token sesi yang valid.
- Backend bertanggung jawab memvalidasi kepemilikan laporan dan hak akses pengguna.
- Izin kamera dan lokasi diperlukan untuk menjalankan fitur pengambilan foto dan koordinat.
- Informasi sensitif seperti token, password, dan kredensial database tidak boleh dimasukkan ke repository publik.

## 🎯 Project Goals

ROADIS dikembangkan untuk mendukung digitalisasi pelaporan kerusakan jalan melalui integrasi teknologi mobile, computer vision, dan pemetaan digital.

Tujuan utamanya adalah membantu masyarakat mendokumentasikan kerusakan jalan secara lebih mudah serta menyediakan informasi yang terstruktur untuk mendukung proses pemantauan dan penanganan laporan infrastruktur.

## 🔮 Future Improvements

- Peningkatan akurasi deteksi kerusakan jalan.
- Optimasi kecepatan inferensi pada perangkat Android.
- Penyempurnaan validasi lokasi dan wilayah kewenangan jalan.
- Peningkatan visualisasi laporan pada peta.
- Pengembangan analitik laporan untuk mendukung prioritas penanganan jalan.

## 👨‍💻 Development

ROADIS Mobile dikembangkan menggunakan Flutter dan Dart, dengan dukungan backend REST API serta model AI untuk deteksi kerusakan jalan.

**Repository:** ROADIS Mobile  
**Platform:** Android  
**Project Type:** Mobile Application · Computer Vision · GIS

---

<p align="center">
  <strong>ROADIS — Towards Smarter Road Infrastructure Reporting</strong>
</p>
