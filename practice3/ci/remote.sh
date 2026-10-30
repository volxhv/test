#!/bin/sh
set -eu
mode=${1:?mode}; tag=${2:?tag}; color=${3:-green}
case "$color" in blue) port=9443;; green) port=9445;; *) echo 'color must be blue or green' >&2; exit 2;; esac
cd /opt/devops-stack
case "$mode" in
 prepare)
   # Values are received through stdin, never shell-interpolated into an SSH command.
   umask 077
   IFS= read -r backend; IFS= read -r frontend; IFS= read -r nginx; IFS= read -r password
   case "$password" in *[!a-zA-Z0-9_-]*|'') echo 'DB_PASSWORD: only letters, digits, _ and -' >&2; exit 2;; esac
   printf 'BACKEND_IMAGE=%s\nFRONTEND_IMAGE=%s\nNGINX_IMAGE=%s\nDB_PASSWORD=%s\nIMAGE_TAG=%s\nCOLOR=%s\nCOLOR_PORT=%s\n' "$backend" "$frontend" "$nginx" "$password" "$tag" "$color" "$port" > "$color.env"
   ;;
 deploy)
   docker compose -p "practice3-$color" --env-file "$color.env" -f compose.yml pull
   docker compose -p "practice3-$color" --env-file "$color.env" -f compose.yml up -d --remove-orphans
   for i in $(seq 1 60); do curl -fsS "http://nginx-$color/api/health" >/dev/null && exit 0; sleep 3; done
   echo 'New stack failed health check; gateway not switched' >&2; exit 1
   ;;
 switch)
   curl -fsS "http://nginx-$color/api/health" >/dev/null
   # Validate the colour above; variable interpolation is restricted to blue or green.
   docker exec practice3-gateway sh -c "printf '%s\n' 'server { listen 8443 ssl; ssl_certificate /etc/nginx/tls/cert.pem; ssl_certificate_key /etc/nginx/tls/key.pem; location / { proxy_pass http://nginx-$color:80; } }' > /etc/nginx/conf.d/default.conf && nginx -t && nginx -s reload"
   ;;
 canary)
   CANARY_TAG="$tag" docker compose -p "practice3-$color" --env-file "$color.env" -f compose.yml -f compose.canary.yml up -d --no-deps backend-canary
   ready=0; for i in $(seq 1 30); do if curl -fsS http://host.docker.internal:8444/api/health >/dev/null; then ready=1; break; fi; sleep 2; done
   [ "$ready" -eq 1 ] || { echo "Canary did not become ready" >&2; exit 1; }
   ok=0; for i in $(seq 1 100); do curl -fsS http://host.docker.internal:8444/api/health >/dev/null && ok=$((ok+1)) || true; done
   echo "canary: $ok/100"; [ "$ok" -ge 99 ]
   ;;
 canary-stop)
   CANARY_TAG="$tag" docker compose -p "practice3-$color" --env-file "$color.env" -f compose.yml -f compose.canary.yml stop backend-canary
   CANARY_TAG="$tag" docker compose -p "practice3-$color" --env-file "$color.env" -f compose.yml -f compose.canary.yml rm -f backend-canary
   ;;
 *) echo 'unknown action' >&2; exit 2;;
esac
