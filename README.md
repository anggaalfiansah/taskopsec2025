# SEVIMA SRE Selection Task 2025
**Candidate:** Angga Alfiansah  
**Position:** Site Reliability Engineer (SRE)  
**Target:** PT. Sentra Vidya Utama (SEVIMA)

## 📌 Ringkasan Proyek
Repositori ini berisi solusi lengkap untuk seleksi teknis SRE SEVIMA yang terdiri dari dua tugas utama:
1.  **Task 1: Infrastructure Provisioning** (Perancangan Jaringan Skala Nasional dengan Cisco Packet Tracer).
2.  **Task 2: Make Your Web Great Again** (Otomatisasi Server, Internal PKI, dan Load Balancing berbasis Docker).

---

## 🛠️ Ringkasan Solusi

### [Task 1] Infrastructure Provisioning
Merancang topologi jaringan yang menghubungkan Data Center pusat dengan 3 cabang besar (Jakarta, Bandung, Surabaya).
* **File Utama**: `sevima-topology.pkt`
* **Key Features**: Routing antar cabang, manajemen segmen IP, dan validasi konektivitas End-to-End.
* **Dokumentasi**: Screenshot hasil ping tersedia di folder `/infrastruktur/screenshoot`.

### [Task 2] Make Your Web Great Again
Implementasi *Infrastructure as Code* (IaC) untuk mengelola layanan web yang kompleks dalam satu ekosistem kontainer.
* **Teknologi**: Docker, Shell Scripting, HAProxy, Nginx, Apache.
* **Key Features**:
    * **User Automation**: Batch creation 1300 user administratif.
    * **Internal PKI**: Otomatisasi pendaftaran SSL melalui Internal CA.
    * **Traffic Management**: Load Balancing Round-Robin & SSL Termination.
    * **Self-Healing & Test**: Skrip validasi otomatis saat container startup.

---

## 📂 Struktur Repositori
```text
.
└── 📁sevima-devops (Root)
    ├── 📁task-1-networking
    │   ├── 📁screenshots
    │   │   ├── ping-pc-bandung-to-server.png
    │   │   ├── ping-pc-jakarta-to-server.png
    │   │   ├── ping-pc-surabaya-to-server.png
    │   │   └── topologi-overview.png
    │   └── dc-topology.pkt
    ├── 📁task-2-server
    │   ├── 📁config
    │   │   ├── 📁apache
    │   │   │   ├── ports.conf
    │   │   │   └── utara.conf
    │   │   ├── 📁haproxy
    │   │   │   └── haproxy.cfg
    │   │   ├── 📁nginx
    │   │   │   ├── barat.conf
    │   │   │   └── timur.conf
    │   │   └── 📁ssh
    │   │       └── sshd_config
    │   ├── 📁scripts
    │   │   ├── entrypoint.sh
    │   │   ├── setup_ca.sh
    │   │   ├── setup_users.sh
    │   │   └── validate_internal.sh
    │   ├── 📁screenshots
    │   │   ├── barat-secure-https.png
    │   │   └── validation-result.png
    │   ├── Dockerfile
    │   ├── docker-compose.yml
    │   ├── manage_sevime.bat
    │   └── README.md (Spesifik Task 2)
    ├── webgreat_sevima.pdf (Laporan Utama)
    └── README.md (Root Project Dokumentasi)

```

---

## 🚀 Persiapan & Pengujian (Task 2)

### 1. Jalankan Infrastruktur

Pastikan Docker terinstal, lalu jalankan perintah berikut di root folder:

```bash
docker-compose up -d --build

```

### 2. Verifikasi Otomatis

Setelah container berjalan, sistem akan melakukan self-test. Cek hasilnya dengan:

```bash
docker logs -f sevima-task2-ubuntu

```

### 3. Setup Client (Windows)

Untuk mengakses domain internal (sevima.site) tanpa peringatan SSL, jalankan skrip berikut dengan akses **Administrator**:

```powershell
.\manage_sevima.bat

```

---

## 📄 Laporan Lengkap

Dokumentasi konfigurasi, rincian teknis, dan hasil validasi akhir dapat ditemukan pada file:
👉 **[webgreat_sevima.pdf](https://github.com/anggaalfiansah/taskopsec2025/blob/main/webgreat_sevima.pdf)**

---

© 2026 Angga Alfiansah.
