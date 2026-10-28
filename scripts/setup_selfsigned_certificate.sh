
#!/bin/bash
set -euo pipefail

# Localizamos el directorio del proyecto y cargamos las variables
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
if [[ ! -f "$SCRIPT_DIR/.env" ]]; then
    echo "ERROR: No existe scripts/.env"
    exit 1
fi

source "$SCRIPT_DIR/.env"

# Comprobamos que las variables necesarias están definidas
: "${OPENSSL_COUNTRY:?Falta OPENSSL_COUNTRY}"
: "${OPENSSL_PROVINCE:?Falta OPENSSL_PROVINCE}"
: "${OPENSSL_LOCALITY:?Falta OPENSSL_LOCALITY}"
: "${OPENSSL_ORGANIZATION:?Falta OPENSSL_ORGANIZATION}"
: "${OPENSSL_ORGUNIT:?Falta OPENSSL_ORGUNIT}"
: "${OPENSSL_COMMON_NAME:?Falta OPENSSL_COMMON_NAME}"
: "${OPENSSL_EMAIL:?Falta OPENSSL_EMAIL}"

# Rutas del certificado y de la clave privada
CERT="/etc/ssl/certs/apache-selfsigned.crt"
KEY="/etc/ssl/private/apache-selfsigned.key"

# El nombre del certificado debe coincidir con la dirección de acceso
if [[ "$OPENSSL_COMMON_NAME" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
    SAN="IP:$OPENSSL_COMMON_NAME"
else
    SAN="DNS:$OPENSSL_COMMON_NAME"
fi

echo "==> Generando certificado autofirmado..."

openssl req \
    -x509 \
    -nodes \
    -days 365 \
    -newkey rsa:2048 \
    -keyout "$KEY" \
    -out "$CERT" \
    -subj "/C=$OPENSSL_COUNTRY/ST=$OPENSSL_PROVINCE/L=$OPENSSL_LOCALITY/O=$OPENSSL_ORGANIZATION/OU=$OPENSSL_ORGUNIT/CN=$OPENSSL_COMMON_NAME/emailAddress=$OPENSSL_EMAIL" \
    -addext "subjectAltName=$SAN"

chmod 600 "$KEY"
chmod 644 "$CERT"

echo "==> Copiando configuraciones de Apache..."

cp "$PROJECT_DIR/conf/000-default.conf" /etc/apache2/sites-available/000-default.conf
cp "$PROJECT_DIR/conf/default-ssl.conf" /etc/apache2/sites-available/default-ssl.conf

echo "==> Activando módulos y sitio HTTPS..."

a2enmod ssl rewrite
a2ensite default-ssl.conf

echo "==> Comprobando la configuración de Apache..."
apache2ctl configtest

echo "==> Recargando Apache..."
systemctl reload apache2

echo "==> ¡HTTPS configurado correctamente!"
echo "Certificado: $CERT"
echo "Clave privada: $KEY"
