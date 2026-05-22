#!/usr/bin/env bash
# ══════════════════════════════════════════════════════════════════════════════
# SIGESPU Lota — Script de deploy en producción (Hetzner CX22 / Ubuntu 24.04)
#
# Uso:
#   chmod +x deploy.sh
#   ./deploy.sh
#
# Prerrequisitos en el VPS (ejecutar UNA VEZ antes):
#   apt update && apt install -y docker.io docker-compose-plugin certbot
#   systemctl enable --now docker
# ══════════════════════════════════════════════════════════════════════════════
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="$REPO_DIR/.env.production"
COMPOSE_FILE="$REPO_DIR/docker-compose.prod.yml"

# ── 1. Verificar .env.production ──────────────────────────────────────────────
if [ ! -f "$ENV_FILE" ]; then
  echo "ERROR: $ENV_FILE no encontrado."
  echo "  Copia .env.example, guárdalo como .env.production y rellena los valores."
  exit 1
fi

# Cargar variables
set -a; source "$ENV_FILE"; set +a

# Validar que no queden placeholders
REQUIRED_VARS=(DB_PASSWORD JWT_SECRET DOMAIN ALLOWED_ORIGIN SMTP_PASS)
for VAR in "${REQUIRED_VARS[@]}"; do
  VAL="${!VAR:-}"
  if [ -z "$VAL" ] || [[ "$VAL" == *"CAMBIAR"* ]]; then
    echo "ERROR: $VAR no está configurado o aún tiene el valor placeholder en .env.production"
    exit 1
  fi
done

echo "✓ Variables de entorno validadas"

# ── 2. Obtener certificado SSL con certbot (primera vez) ──────────────────────
CERT_PATH="/etc/letsencrypt/live/${DOMAIN}/fullchain.pem"
if [ ! -f "$CERT_PATH" ]; then
  echo "→ Obteniendo certificado SSL para ${DOMAIN}..."
  echo "  (Asegúrate de que el puerto 80 esté libre y el DNS apunte a este VPS)"
  certbot certonly --standalone \
    --domain "$DOMAIN" \
    --email "$SMTP_USER" \
    --agree-tos \
    --no-eff-email \
    --non-interactive
  echo "✓ Certificado SSL obtenido"
else
  echo "✓ Certificado SSL ya existe en $CERT_PATH"
fi

# ── 3. Configurar renovación automática ───────────────────────────────────────
CRON_JOB="0 3 * * * certbot renew --quiet && docker compose -f $COMPOSE_FILE --env-file $ENV_FILE exec nginx nginx -s reload"
(crontab -l 2>/dev/null | grep -qF "certbot renew") || {
  (crontab -l 2>/dev/null; echo "$CRON_JOB") | crontab -
  echo "✓ Cron de renovación SSL configurado (03:00 diario)"
}

# ── 4. Build y deploy ─────────────────────────────────────────────────────────
echo "→ Construyendo imágenes..."
docker compose -f "$COMPOSE_FILE" --env-file "$ENV_FILE" build --no-cache

echo "→ Iniciando servicios..."
docker compose -f "$COMPOSE_FILE" --env-file "$ENV_FILE" up -d

# ── 5. Healthcheck ────────────────────────────────────────────────────────────
echo "→ Esperando que el backend esté listo..."
RETRIES=20
until curl -sf "http://localhost:8080/api/health" > /dev/null 2>&1 || [ $RETRIES -eq 0 ]; do
  sleep 3
  RETRIES=$((RETRIES - 1))
done

if [ $RETRIES -eq 0 ]; then
  echo "ERROR: El backend no respondió después de 60 segundos."
  echo "  Revisa los logs: docker compose -f $COMPOSE_FILE logs backend"
  exit 1
fi

# ── 6. Resumen ────────────────────────────────────────────────────────────────
echo ""
echo "══════════════════════════════════════════════"
echo "✅ SIGESPU Lota deployado exitosamente"
echo "   URL:     https://${DOMAIN}"
echo "   Health:  https://${DOMAIN}/api/health"
echo ""
echo "Comandos útiles:"
echo "  Ver logs:     docker compose -f $COMPOSE_FILE logs -f"
echo "  Reiniciar:    docker compose -f $COMPOSE_FILE restart"
echo "  Detener:      docker compose -f $COMPOSE_FILE down"
echo "  Actualizar:   git pull && ./deploy.sh"
echo "══════════════════════════════════════════════"
