#!/bin/bash
set -e

DIR="/root/ca"
CA_SUBJ="/C=ID/ST=JawaTimur/L=Surabaya/O=PT. Sentra Vidya Utama/CN=SEVIMA CA"
DOMAINS=("www.sevima.site" "utara.sevima.site" "timur.sevima.site" "barat.sevima.site")

mkdir -p "$DIR"
cd "$DIR"

echo "🔐 Generating Root CA (OpenSSL 3.x compatible)"

# =======================
# ROOT CA CONFIG
# =======================
cat > openssl-ca.cnf <<'EOF'
[ req ]
default_bits       = 4096
distinguished_name = dn
x509_extensions    = v3_ca
prompt             = no

[ dn ]
C  = ID
ST = JawaTimur
L  = Surabaya
O  = PT. Sentra Vidya Utama
CN = SEVIMA CA

[ v3_ca ]
basicConstraints = critical, CA:TRUE
keyUsage = critical, keyCertSign, cRLSign
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid:always,issuer
EOF

openssl genrsa -out cacert.key 4096

openssl req -x509 -new -nodes \
  -key cacert.key \
  -sha256 \
  -days 3650 \
  -out cacert.pem \
  -config openssl-ca.cnf

rm openssl-ca.cnf

echo "✅ Root CA OK"

# =======================
# LEAF CERTIFICATES
# =======================
for domain in "${DOMAINS[@]}"; do
  echo "🔑 Generating cert for $domain"

  cat > openssl-$domain.cnf <<EOF
[ req ]
default_bits       = 2048
distinguished_name = dn
req_extensions     = v3_req
prompt             = no

[ dn ]
C  = ID
ST = JawaTimur
L  = Surabaya
O  = PT. Sentra Vidya Utama
CN = $domain

[ v3_req ]
basicConstraints = CA:FALSE
keyUsage = digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth
subjectAltName = DNS:$domain, DNS:localhost
EOF

  openssl genrsa -out "$domain.key" 2048

  openssl req -new \
    -key "$domain.key" \
    -out "$domain.csr" \
    -config openssl-$domain.cnf

  openssl x509 -req \
    -in "$domain.csr" \
    -CA cacert.pem \
    -CAkey cacert.key \
    -CAserial ca.srl \
    -out "$domain.crt" \
    -days 365 \
    -sha256 \
    -extensions v3_req \
    -extfile openssl-$domain.cnf

  cat "$domain.crt" "$domain.key" > "$domain.pem"

  rm "$domain.csr" openssl-$domain.cnf
done

echo "✅ All certificates generated successfully (Docker-safe)"
