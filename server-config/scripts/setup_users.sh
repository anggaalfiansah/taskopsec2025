#!/bin/bash
# ==============================================================================
# SCRIPT NAME: setup_users.sh (BATCH + LOGGING + LIMITS)
# AUTHOR     : Angga Alfiansah
# ==============================================================================

USER_LIST="/tmp/user_list.txt"
SKEL_SSH="/etc/skel/.ssh"
LIMIT_CONF="/etc/security/limits.d/sevima-limits.conf"

echo "🔍 [PRE-CHECK] Memverifikasi integritas sistem..."

# --- 1. OTOMATISASI SUDO (Soal A.1) ---
# Ambil GID sudo secara dinamis agar user otomatis jadi admin
SUDO_GID=$(getent group sudo | cut -d: -f3)
if [ -z "$SUDO_GID" ]; then
    groupadd -g 27 sudo
    SUDO_GID=27
fi
echo "✅ Grup sudo terdeteksi (GID: $SUDO_GID)"

# --- 2. PREPARASI SSH TEMPLATE (Soal A.1) ---
# Menggunakan /etc/skel agar SSH key otomatis terdistribusi
mkdir -p "$SKEL_SSH"
ssh-keygen -t rsa -b 2048 -f "$SKEL_SSH/id_rsa" -N "" -q
cp "$SKEL_SSH/id_rsa.pub" "$SKEL_SSH/authorized_keys"
chmod 700 "$SKEL_SSH" && chmod 600 "$SKEL_SSH/authorized_keys" "$SKEL_SSH/id_rsa"

# --- 3. BATCH USER CREATION (Soal A.1) ---
# Format: username:password:UID:GID(Sudo):comment:home:shell
echo "[LOG] Menyusun 1300 entri user dengan password dinamis..."
> "$USER_LIST"
for i in {1..1300}
do
    UID_VAL=$((2000 + i))
    echo "sevima-adm$i:w3bsite#$i:$UID_VAL:$SUDO_GID:User Sevima:/home/sevima-adm$i:/bin/bash" >> "$USER_LIST"
done

# Eksekusi instan
newusers "$USER_LIST"

# --- 4. AKTIVASI SELURUH LOG (Soal A.3) ---
# Mengaktifkan module rsyslog untuk mencatat aktivitas sistem
echo "[LOG] Mengaktifkan modul rsyslog (imklog & imuxsock)..."
if [ -f /etc/rsyslog.conf ]; then
    sed -i 's/^#module(load="imuxsock")/module(load="imuxsock")/' /etc/rsyslog.conf
    sed -i 's/^#module(load="imklog")/module(load="imklog")/' /etc/rsyslog.conf
fi

# --- 5. RESOURCE LIMITS (Soal A.4) ---
# Mengatur batas file descriptor 65535
echo "[LOG] Mengonfigurasi resource limits..."
cat <<EOF > "$LIMIT_CONF"
# Sevima Sysadmin Task: Resource Limits
* soft    nofile  65535
* hard    nofile  65535
* soft    nproc   4096
* hard    nproc   8192
root    soft    nofile  65535
root    hard    nofile  65535
EOF

# 6. Cleanup
rm "$USER_LIST"
rm -rf "$SKEL_SSH"

echo "========================================================"
echo "✅ [SUCCESS] Konfigurasi Soal A Selesai (50s Record)!"
echo "========================================================"