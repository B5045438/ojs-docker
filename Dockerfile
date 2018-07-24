FROM ubuntu:latest
MAINTAINER Ammar Hasan <b5045438@ncl.ac.uk>

# Install packages
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && \
  apt-get -y install composer npm supervisor git apache2 libapache2-mod-php7.2 mysql-server php7.2-mysql pwgen curl php7.2-curl php7.2-xml zip unzip php-zip php-mbstring && \
  echo "ServerName localhost" >> /etc/apache2/apache2.conf 

# Add volumes for MySQL
VOLUME  ["/etc/mysql", "/var/lib/mysql"]

# Add image configuration and scripts
ADD start-apache2.sh /start-apache2.sh
ADD start-mysqld.sh /start-mysqld.sh
ADD run.sh /run.sh
RUN chmod 755 /*.sh
ADD my.cnf /etc/mysql/conf.d/my.cnf
ADD supervisord-apache2.conf /etc/supervisor/conf.d/supervisord-apache2.conf
ADD supervisord-mysqld.conf /etc/supervisor/conf.d/supervisord-mysqld.conf

# Remove pre-installed database
RUN rm -rf /var/lib/mysql/*

# Add MySQL utils
ADD create_mysql_admin_user.sh /create_mysql_admin_user.sh
RUN chmod 755 /*.sh

# MySQL Home DIR fix
RUN  usermod -d /var/lib/mysql/ mysql && find /var/lib/mysql -type f -exec touch {} \; && service mysql start

# config to enable .htaccess
ADD apache_default /etc/apache2/sites-available/000-default.conf
RUN a2enmod rewrite

# Cloning, cleaning, seting up OJS git repositories and plugins
RUN apt-get install git -y \
    && git config --global url.https://.insteadOf git:// \
    && rm -fr /var/www/html/* \
    && git clone -v --recursive --progress --single-branch -b ojs-stable-3_1_1 https://github.com/pkp/ojs.git /var/www/html \
    && cd /var/www/html/lib/pkp \
    && COMPOSER_ALLOW_SUPERUSER=1 composer update \
    && cd /var/www/html/plugins/paymethod/paypal \
    && COMPOSER_ALLOW_SUPERUSER=1 composer update \
    && cd /var/www/html/plugins/generic/citationStyleLanguage \
    && COMPOSER_ALLOW_SUPERUSER=1 composer update \
    && git clone -v --progress https://github.com/Vitaliy-1/oldGregg.git /var/www/html/plugins/themes/oldGregg \
    && cd /var/www/html \
    && npm install \ 
    && npm run build \
    && find . | grep .git | xargs rm -rf \
    && cp /var/www/html/config.TEMPLATE.inc.php /var/www/html/config.inc.php \
    && chmod ug+rw /var/www/html/config.inc.php \
    && mkdir -p /var/www/files/ \
    && chown -R www-data:www-data /var/www/  

#Environment variables to configure php
ENV PHP_UPLOAD_MAX_FILESIZE 10M
ENV PHP_POST_MAX_SIZE 10M

EXPOSE 80 443
CMD ["/run.sh"]

