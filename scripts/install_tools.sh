
#!/bin/bash

# Actualizamos la lista de paquetes
apt update

# Instalamos las herramientas necesarias
apt install -y phpmyadmin adminer goaccess apache2-utils

# Activamos la configuración de phpMyAdmin si existe
if [ -f /etc/apache2/conf-available/phpmyadmin.conf ]; then
    a2enconf phpmyadmin
fi

# Creamos un acceso sencillo a Adminer
if [ -f /usr/share/adminer/adminer.php ]; then
    ln -sf /usr/share/adminer/adminer.php /var/www/html/adminer.php
fi

# Creamos el directorio privado
mkdir -p /var/www/html/privado

# Copiamos el archivo .htaccess
cp ../htaccess/.htaccess /var/www/html/privado/.htaccess

# Creamos una página de prueba en la zona privada
echo "<h1>Zona privada</h1>" > /var/www/html/privado/index.html

# Creamos el archivo de contraseñas si todavía no existe
if [ ! -f /etc/apache2/.htpasswd ]; then
    htpasswd -c /etc/apache2/.htpasswd alumno
fi

# Ajustamos los permisos del directorio privado
chown -R www-data:www-data /var/www/html/privado

# Comprobamos la configuración de Apache
apache2ctl configtest

# Reiniciamos Apache
systemctl restart apache2

echo "Instalación de herramientas completada"
