#!/bin/bash
set -x

# Configuramos las variables con los datos que necesita el certificado
OPENSSL_COUNTRY="ES"
OPENSSL_PROVINCE="Almeria"
OPENSSL_LOCALITY="Almeria"
OPENSSL_ORGANIZATION="IES Celia"
OPENSSL_ORGUNIT="Departamento de Informatica"
OPENSSL_COMMON_NAME="practica-https.local"
OPENSSL_EMAIL="admin@iescelia.org"

# Creamos el certificado autofirmado
sudo openssl req \
  -x509 \
  -nodes \
  -days 365 \
  -newkey rsa:2048 \
  -keyout /etc/ssl/private/apache-selfsigned.key \
  -out /etc/ssl/certs/apache-selfsigned.crt \
  -subj "/C=$OPENSSL_COUNTRY/ST=$OPENSSL_PROVINCE/L=$OPENSSL_LOCALITY/O=$OPENSSL_ORGANIZATION/OU=$OPENSSL_ORGUNIT/CN=$OPENSSL_COMMON_NAME/emailAddress=$OPENSSL_EMAIL"