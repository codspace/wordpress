#!/bin/bash

# https://ubuntu.com/tutorials/install-and-configure-wordpress

DEBIAN_FRONTEND="noninteractive"

# Check running as root
if [ $(id -u) -ne 0 ]
  then echo "Please run as root"
  exit 1
fi

apt update -y
apt install -y apache2 \
                 ghostscript \
                 libapache2-mod-php \
                 mysql-server \
                 php \
                 php-bcmath \
                 php-curl \
                 php-imagick \
                 php-intl \
                 php-json \
                 php-mbstring \
                 php-mysql \
                 php-xml \
                 php-zip

sudo mkdir -p /srv/www
sudo chown www-data: /srv/www
curl https://wordpress.org/latest.tar.gz | sudo -u www-data tar zx -C /srv/www

# Start mysql
service mysql start

# Create wordpress.conf
cat <<EOF > /etc/apache2/sites-available/wordpress.conf
<VirtualHost *:80>
    DocumentRoot /srv/www/wordpress
    <Directory /srv/www/wordpress>
        Options FollowSymLinks
        AllowOverride Limit Options FileInfo
        DirectoryIndex index.php
        Require all granted
    </Directory>
    <Directory /srv/www/wordpress/wp-content>
        Options FollowSymLinks
        Require all granted
    </Directory>
</VirtualHost>
EOF

a2ensite wordpress
a2enmod rewrite

a2dissite 000-default
service apache2 reload
service apache2 restart

# Create database
mysql -u root -e "CREATE DATABASE wordpress;"
mysql -u root -e "CREATE USER wordpress@localhost IDENTIFIED BY 'wordpress';"
mysql -u root -e "GRANT ALL PRIVILEGES ON wordpress.* TO wordpress@localhost;"
mysql -u root -e "FLUSH PRIVILEGES;"

