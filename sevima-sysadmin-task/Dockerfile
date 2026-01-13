# ==============================================================================
# FILENAME: Dockerfile
# DESCRIPTION: Definisi infrastruktur container berbasis Ubuntu 22.04.
# TASK       : SEVIMA Sysadmin Task - Core Image
# AUTHOR     : Angga Alfiansah
# ==============================================================================

# Menggunakan base image Ubuntu LTS terbaru untuk stabilitas
FROM ubuntu:22.04

# Konfigurasi Environment agar instalasi berjalan non-interaktif
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Jakarta

# --- 1. INSTALASI DEPENDENSI (Soal A, C, & D) ---
# Menginstal semua layanan yang dibutuhkan: SSH, Apache, Nginx, HAProxy.
RUN apt-get update && apt-get install -y --no-install-recommends \
    openssh-server \
    apache2 \
    nginx \
    haproxy \
    sudo \
    openssl \
    rsyslog \
    curl \
    vim \
    iputils-ping \
    net-tools \
    dos2unix \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# --- 2. KONFIGURASI RUNTIME ---
# Menyiapkan direktori runtime untuk daemon SSH
RUN mkdir -p /var/run/sshd

# Aktivasi modul header Apache untuk manipulasi X-Served-By
RUN a2enmod headers \
 && echo "ServerName localhost" >> /etc/apache2/apache2.conf

# --- 3. MANAJEMEN SKRIP & OTOMASI ---
# Menyalin skrip setup ke dalam container secara batch
COPY scripts/ /usr/local/bin/

# Memberikan izin eksekusi dan memperbaiki format line-ending (CRLF to LF)
RUN chmod +x /usr/local/bin/*.sh \
 && dos2unix /usr/local/bin/*.sh

# Menjalankan provisioning user saat build time
RUN /usr/local/bin/setup_users.sh

# Menjalankan pembentukan Internal Certificate Authority saat build time
RUN /usr/local/bin/setup_ca.sh

# Membersihkan konfigurasi default Nginx agar tidak bentrok dengan Soal C
RUN rm -f /etc/nginx/sites-available/default \
 && rm -f /etc/nginx/sites-enabled/default

# --- 4. EXPOSURE & EXECUTION ---
# Port: 2025(SSH), 8069(Apache), 8169(Nginx), 4435(HTTPS), 80(LB)
EXPOSE 2025 8069 8169 4435 80

# Menetapkan entrypoint.sh sebagai orchestrator utama layanan
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]