#!/bin/bash

# ==============================================================================
# SCRIPT NAME: entrypoint.sh
# DESCRIPTION: Orchestrator startup untuk layanan Apache, Nginx, dan HAProxy.
# TASK       : SEVIMA Sysadmin Task - Main Entrypoint
# AUTHOR     : Angga Alfiansah
# ==============================================================================

echo "========================================================"
echo "🔥 [START] SEVIMA CONTAINER INITIALIZATION"
echo "========================================================"

# --- 1. STATIC CONTENT DEPLOYMENT (Soal C) ---
# Memastikan direktori web tersedia dan memiliki konten index yang sesuai.
echo "[LOG] Mendistribusikan konten statis ke direktori web..."

sites=("utara" "timur" "barat")
for site in "${sites[@]}"; do
    mkdir -p "/var/www/html/$site"
    # Menentukan teks konten berdasarkan nama site (khusus Barat ditandai HTTPS)
    CONTENT="Hello World from ${site^} Site"
    [[ "$site" == "barat" ]] && CONTENT="$CONTENT (HTTPS)"
    
    echo "$CONTENT" > "/var/www/html/$site/index.html"
    chown -R www-data:www-data "/var/www/html/$site"
done

# --- 2. SSL CERTIFICATE DEPLOYMENT (Soal D) ---
# Menyiapkan sertifikat gabungan (.pem) untuk kebutuhan HAProxy SSL termination.
echo "[LOG] Mengonfigurasi SSL Certificates untuk HAProxy..."
mkdir -p /etc/haproxy/certs
if [ -f /root/ca/www.sevima.site.pem ]; then
    cp /root/ca/www.sevima.site.pem /etc/haproxy/certs/
    chown -R haproxy:haproxy /etc/haproxy/certs
    chmod 600 /etc/haproxy/certs/*.pem
else
    echo "[WARN] Sertifikat www.sevima.site.pem tidak ditemukan!"
fi

# --- 3. SERVICE STARTUP SEQUENCE ---
# Urutan sangat penting: HAProxy dimulai pertama untuk mengunci Port 80.
echo "--------------------------------------------------------"
echo "🚀 [INIT] Memulai Layanan Sistem..."

echo "[1/4] HAProxy (Load Balancer Port 80/443)..."
haproxy -c -f /etc/haproxy/haproxy.cfg && service haproxy start

echo "[2/4] SSH Service (Port 2025)..."
service ssh start

echo "[3/4] Apache2 (Backend Utara - Port 8069)..."
service apache2 start

echo "[4/4] Nginx (Backend Timur/Barat - Port 8169/4435)..."
service nginx start

echo "✅ Semua layanan berhasil dijalankan!"

# --- 4. AUTOMATED POST-DEPLOYMENT TEST ---
# Melakukan validasi internal untuk memastikan semua kriteria soal terpenuhi.
echo "--------------------------------------------------------"
echo "⏳ Menunggu stabilitas port (5 detik)..."
sleep 5

TARGET_TEST="/usr/local/bin/validate_internal.sh"
if [ -f "$TARGET_TEST" ]; then
    echo "[LOG] Menjalankan test validasi otomatis..."
    chmod +x "$TARGET_TEST"
    "$TARGET_TEST"
else
    echo "[ERROR] Script validasi internal tidak ditemukan!"
fi

echo "========================================================"
echo "🏁 [READY] Container aktif. Menunggu koneksi..."
echo "========================================================"

# Menjaga container tetap berjalan di foreground.
tail -f /dev/null