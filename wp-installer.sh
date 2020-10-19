#!/bin/bash

# Script to install LAMP stack and WordPress site on a fresh server (Ubuntu LTS 16.04)

# STEPS:
# Get user input

# Update & Upgrade Ubuntu
# Install Apache2
# Install MariaDB
# My_Sql secure install
# Install php7.4

# Install WordPress files
# Configure Apache2
# Enable Wordpress
# Restart Apache2

# Install git and clone new copy of WordPress
# Change owner to allow WordPress to access folders for plugins

read -p 'Username: ' username
read -sp 'Password: ' password
read -sp 'Confirm Password: ' password2

if [ $password != $password2 ]; then
  echo 'Passwords do not match.  Try again.'
  exit N
fi

echo "Installing LAMP stack" 2>&1 | tee -a InstallationProgress.txt

echo "Updating and Upgrading Linux" 2>&1 | tee -a InstallationProgress.txt

apt-get -y update && apt-get -y upgrade 2>&1 | tee -a InstallationProgress.txt

echo "#################################################" 2>&1 | tee -a InstallationProgress.txt

echo "Installing Apache2" 2>&1 | tee -a InstallationProgress.txt

apt install apache2 2>&1 | tee -a InstallationProgress.txt

systemctl status apache2 2>&1 | tee -a InstallationProgress.txt

echo "#################################################" 2>&1 | tee -a InstallationProgress.txt

echo "Installing php7.4" 2>&1 | tee -a InstallationProgress.txt

echo "deb http://ppa.launchpad.net/ondrej/php/ubuntu xenial main" >> /etc/apt/sources.list

echo "deb-src http://ppa.launchpad.net/ondrej/php/ubuntu xenial main" >> /etc/apt/sources.list

# apt-get update
# Change error key and execute, then repeat apt-get update:
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 4F4EA0AAE5267A6C

apt-get update -y

apt-get install -y php7.4


apt update -y

apt install -y php7.4 php7.4-cli php7.4-common php7.4-fpm

apt install -y php7.4-mysql php7.4-dom php7.4-simplexml php7.4-ssh2 php7.4-xml php7.4-xmlreader php7.4-curl  php7.4-exif  php7.4-ftp php7.4-gd  php7.4-iconv php7.4-imagick php7.4-json  php7.4-mbstring php7.4-posix php7.4-sockets php7.4-tokenizer

apt install -y php7.4-mysqli php7.4-pdo  php7.4-sqlite3 php7.4-ctype php7.4-fileinfo php7.4-zip php7.4-exif


apt install -y mariadb-server mariadb-client 2>&1 | tee -a InstallationProgress.txt

echo "Securely installing My_Sql..." 2>&1 | tee -a InstallationProgress.txt

mysql_secure_installation 2>&1 | tee -a InstallationProgress.txt

echo "Setting up WordPress DB" 2>&1 | tee -a InstallationProgress.txt

# must be improved
mysql --user=root --password=$password -e "CREATE DATABASE wordpress_db;"
mysql --user=root --password=$password --database=wordpress_db -e "CREATE USER '${username}'@'localhost' IDENTIFIED BY '${password}';"
mysql --user=root --password=$password --database=wordpress_db -e "GRANT ALL ON wordpress_db.* TO '${username}'@'localhost' IDENTIFIED BY '${password}';"
mysql --user=root --password=$password --database=wordpress_db -e "FLUSH PRIVILEGES;"

# Install WordPress
apt install wordpress

# Write WordPress config files
echo 'Alias /blog /usr/share/wordpress' >> /etc/apache2/sites-available/wordpress.conf
echo '<Directory /usr/share/wordpress>' >> /etc/apache2/sites-available/wordpress.conf
echo '    Options FollowSymLinks' >> /etc/apache2/sites-available/wordpress.conf
echo '    AllowOverride Limit Options FileInfo' >> /etc/apache2/sites-available/wordpress.conf
echo '    DirectoryIndex index.php' >> /etc/apache2/sites-available/wordpress.conf
echo '    Order allow,deny' >> /etc/apache2/sites-available/wordpress.conf
echo '    Allow from all' >> /etc/apache2/sites-available/wordpress.conf
echo '</Directory>' >> /etc/apache2/sites-available/wordpress.conf
echo '<Directory /usr/share/wordpress/wp-content>' >> /etc/apache2/sites-available/wordpress.conf
echo '    Options FollowSymLinks' >> /etc/apache2/sites-available/wordpress.conf
echo '    Order allow,deny' >> /etc/apache2/sites-available/wordpress.conf
echo '    Allow from all' >> /etc/apache2/sites-available/wordpress.conf
echo '</Directory>' >> /etc/apache2/sites-available/wordpress.conf


echo "<?php" >> /etc/wordpress/config-com.php
echo "define('DB_NAME', 'wordpress_db');" >> /etc/wordpress/config-com.php
echo "define('DB_USER', '${username}');" >> /etc/wordpress/config-com.php
echo "define('DB_PASSWORD', '${password}');" >> /etc/wordpress/config-com.php
echo "define('DB_HOST', 'localhost');" >> /etc/wordpress/config-com.php
echo "define('DB_COLLATE', 'utf8_general_ci');" >> /etc/wordpress/config-com.php
echo "define('WP_CONTENT_DIR', '/usr/share/wordpress/wp-content');" >> /etc/wordpress/config-com.php
echo "?>" >> /etc/wordpress/config-com.php


service mysql start

a2ensite wordpress

a2enmod rewrite

service apache2 reload

systemctl restart apache2

# Print version information for LAMP stack components

echo "#################################################" 2>&1 | tee -a InstallationProgress.txt
echo "#################################################" 2>&1 | tee -a InstallationProgress.txt
echo "#################################################" 2>&1 | tee -a InstallationProgress.txt

cat /etc/os-release 2>&1 | tee -a InstallationProgress.txt

apache2 -v 2>&1 | tee -a InstallationProgress.txt

mysql -v 2>&1 | tee -a InstallationProgress.txt

php -v 2>&1 | tee -a InstallationProgress.txt

echo "#################################################" 2>&1 | tee -a InstallationProgress.txt
echo "#################################################" 2>&1 | tee -a InstallationProgress.txt
echo "#################################################" 2>&1 | tee -a InstallationProgress.txt

apt install -y git
cd /var/www && git clone https://github.com/WordPress/WordPress.git && rm -r html
cp -r WordPress html

chown -Rf www-data:www-data /var/www/html

echo "LAMP stack and WordPress installed with specified username and password." 2>&1 | tee -a InstallationProgress.txt
echo "Please visit $(hostname) to setup your new website." 2>&1 | tee -a InstallationProgress.txt

# Go online and setup WP site
