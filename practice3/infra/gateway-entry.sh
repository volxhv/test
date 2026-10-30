#!/bin/sh
set -eu
mkdir -p /etc/nginx/tls
if [ ! -f /etc/nginx/tls/key.pem ]; then
  openssl req -x509 -nodes -newkey rsa:2048 -days 365 -subj '/CN=localhost' -keyout /etc/nginx/tls/key.pem -out /etc/nginx/tls/cert.pem >/dev/null 2>&1
fi
cat > /etc/nginx/conf.d/default.conf <<'EOF'
server { listen 8443 ssl; ssl_certificate /etc/nginx/tls/cert.pem; ssl_certificate_key /etc/nginx/tls/key.pem; location / { return 503; } }
EOF
exec nginx -g 'daemon off;'
