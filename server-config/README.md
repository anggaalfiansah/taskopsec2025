# SEVIMA Sysadmin Task 2025 - Task 2
**Author:** Angga Alfiansah
**Repository:** taskopsec2025

## 📌 Deskripsi Proyek
Proyek ini merupakan implementasi infrastruktur server berbasis Docker yang mencakup manajemen user skala besar (1300 user), konfigurasi keamanan SSH, Certificate Authority (CA) internal, serta Load Balancing menggunakan HAProxy untuk mengelola trafik antara backend Apache (Utara) dan Nginx (Timur & Barat).



## 🛠️ Fitur Utama
* **Provisioning User Masal**: Pembuatan 1300 user administratif secara batch dengan otentikasi SSH Public Key.
* **Automated Internal CA**: Sistem otomatisasi penerbitan SSL Certificate untuk domain internal sevima.site.
* **Load Balancing & SSL Termination**: Distribusi trafik Round-Robin pada Port 80 dan terminasi SSL pada Port 443.
* **Header Obfuscation**: Manipulasi header HTTP `X-Served-By` untuk keamanan dan pemenuhan kriteria teknis.
* **Auto-Validation System**: Sistem pengujian internal otomatis yang berjalan langsung saat container startup.

## 📂 Struktur Folder
```text
server-config/
├── config/
│   ├── apache/        # Konfigurasi VirtualHost & Port Apache
│   ├── haproxy/       # Konfigurasi Load Balancer HAProxy
│   ├── nginx/         # Konfigurasi VirtualHost Nginx (Timur & Barat)
│   └── ssh/           # Konfigurasi Daemon SSH Port 2025
├── scripts/
│   ├── entrypoint.sh       # Orchestrator startup layanan
│   ├── setup_ca.sh         # Script pembentuk SSL CA
│   ├── setup_users.sh      # Script pembuatan 1300 user & Ulimit
│   └── validate_internal.sh # Script pengujian otomatis
├── manage_sevima.bat       # Client-side Automation (Windows)
├── Dockerfile              # Definisi lingkungan Ubuntu 22.04
└── docker-compose.yml      # Orchestrasi container & volume mapping
```

## 🚀 Cara Menjalankan

1. **Clone Repository**:
```bash
git clone https://github.com/anggaalfiansah/taskopsec2025.git
cd server-config

```


2. **Build & Jalankan Container**:
Pastikan Docker dan Docker Compose sudah terinstal.
```bash
docker-compose up -d --build

```


3. **Pantau Hasil Validasi Otomatis**:
Container akan menjalankan test secara otomatis saat startup.
```bash
docker logs -f sevima-task2-ubuntu

```



## 🧪 Detail Validasi

Sistem akan memverifikasi poin-poin berikut:

* **Soal A**: Keberadaan 1300 user, akses sudo, dan konfigurasi Ulimit 65535.
* **Soal C**: Respon HTTP 200 pada port 8069, 8169, dan 4435 (HTTPS).
* **Soal D**: Algoritma Round-Robin HAProxy yang mendistribusikan trafik secara bergantian.

---
