#!/bin/bash
# ==============================================================================
# SCRIPT NAME: validate_internal.sh (FINAL REVISION)
# DESCRIPTION: Validasi Kriteria SEVIMA (User, SSH, Log, Limits, LB, SSL)
# AUTHOR     : Angga Alfiansah
# ==============================================================================

HOST="localhost"
PORT_UTARA=8069
PORT_TIMUR=8169
PORT_BARAT=4435
PORT_LB=80

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo "========================================================"
echo " 🔍 [START] VALIDASI KETAT SISTEM SEVIMA"
echo "========================================================"

# --- 1. VALIDASI SOAL A (KONFIGURASI DASAR) ---
echo -e "\n--- [SOAL A] USER, SSH, LOG & LIMITS ---"

# A.1: User Acak & Sudo
RANDOM_ID=$((1 + RANDOM % 1300))
RANDOM_USER="sevima-adm$RANDOM_ID"
id $RANDOM_USER > /dev/null 2>&1 && groups $RANDOM_USER | grep -q "sudo"
if [ $? -eq 0 ]; then
    echo -e "${GREEN}[PASS]${NC} User Acak: $RANDOM_USER & Sudo Terverifikasi"
else
    echo -e "${RED}[FAIL]${NC} User Acak: $RANDOM_USER Bermasalah"
fi

# A.2: SSH Port 2025
netstat -tulpn | grep -q ":2025" && echo -e "${GREEN}[PASS]${NC} SSH berjalan di Port 2025" || echo -e "${RED}[FAIL]${NC} SSH Port 2025 Mati"

# A.3: Log Aktivitas (Rsyslog Modules)
if grep -q "imuxsock" /etc/rsyslog.conf && grep -q "imklog" /etc/rsyslog.conf; then
    echo -e "${GREEN}[PASS]${NC} Logging System (imuxsock & imklog) Aktif"
else
    echo -e "${RED}[FAIL]${NC} Logging System Belum Aktif"
fi

# A.4: Resource Limits (Ulimit)
SOFT_NOFILE=$(ulimit -Sn)
if [ "$SOFT_NOFILE" == "65535" ]; then
    echo -e "${GREEN}[PASS]${NC} Resource Limits (nofile): $SOFT_NOFILE"
else
    echo -e "${RED}[FAIL]${NC} Resource Limits: $SOFT_NOFILE (Harusnya 65535)"
fi

# --- 2. VALIDASI SOAL B & C (WEB SERVER & SSL) ---
echo -e "\n--- [SOAL B & C] WEB SERVER & CERTIFICATE ---"

# Test UTARA (Apache)
RESP_UTARA=$(curl -s -I -H "Host: utara.sevima.site" http://$HOST:$PORT_UTARA)
if echo "$RESP_UTARA" | grep -q "X-Served-By: apache2"; then
    echo -e "${GREEN}[PASS]${NC} Utara: Header Apache2 Sesuai"
    echo -e "       Konten: $(curl -s -H "Host: utara.sevima.site" http://$HOST:$PORT_UTARA)"
else
    echo -e "${RED}[FAIL]${NC} Utara: Header Tidak Sesuai"
fi

# Test TIMUR (Nginx) - Cek Header apakah berubah atau tidak
RESP_TIMUR=$(curl -s -I -H "Host: timur.sevima.site" http://$HOST:$PORT_TIMUR)
if echo "$RESP_TIMUR" | grep -q "X-Served-By: apache2"; then
    echo -e "${GREEN}[PASS]${NC} Timur: Header apache2 Sesuai"
    echo -e "       Konten: $(curl -s -H "Host: timur.sevima.site" http://$HOST:$PORT_TIMUR)"
else
    echo -e "${RED}[FAIL]${NC} Timur: Header Bermasalah (Ditemukan: $(echo "$RESP_TIMUR" | grep "X-Served-By"))"
fi

# Test BARAT (Redirect 301)
REDIRECT_CODE=$(curl -o /dev/null -s -w "%{http_code}" -H "Host: barat.sevima.site" http://$HOST)
[ "$REDIRECT_CODE" == "301" ] && echo -e "${GREEN}[PASS]${NC} Barat: Redirect 301 Aktif" || echo -e "${RED}[FAIL]${NC} Barat: Redirect Salah ($REDIRECT_CODE)"

# Test SSL
CERT_INFO=$(curl -k -v -H "Host: barat.sevima.site" https://$HOST:$PORT_BARAT 2>&1 | grep "issuer")
echo "$CERT_INFO" | grep -q "SEVIMA CA" && echo -e "${GREEN}[PASS]${NC} Barat: SSL Issuer SEVIMA CA Sesuai" || echo -e "${RED}[FAIL]${NC} Barat: SSL Salah"

# --- 3. VALIDASI SOAL D (LOAD BALANCER) ---
echo -e "\n--- [SOAL D] LOAD BALANCER ---"
echo "Menguji Algoritma Round Robin (Single-Hit Analysis)..."
for i in {1..4}; do
   # Teknik Single-Hit: Ambil Body & Header dalam satu request
   curl -s -i -H "Host: www.sevima.site" --resolve www.sevima.site:80:127.0.0.1 http://www.sevima.site > /tmp/hit.txt
   RESPONSE=$(tail -n 1 /tmp/hit.txt)
   SERVER=$(grep -i "X-Served-By" /tmp/hit.txt | awk -F': ' '{print $2}' | tr -d '\r\n ')
   echo "   Request #$i: $RESPONSE (Served by: $SERVER)"
   rm /tmp/hit.txt
done

echo -e "\n========================================================"
echo " ✅ VALIDASI SELESAI"
echo "========================================================"