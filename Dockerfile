FROM ubuntu:jammy

ENV DEBIAN_FRONTEND=noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN=true

RUN groupadd -g 568 apps
RUN useradd -u 568 -g 568 -m apps

VOLUME /persist
VOLUME /var/www/html

RUN apt update
RUN apt install -y git sudo nginx

RUN apt install -y software-properties-common ca-certificates lsb-release apt-transport-https
RUN add-apt-repository -y ppa:ondrej/php

RUN apt update

RUN apt install -y php8.2-fpm
RUN apt install -y php8.2-dom \
    php8.2-gd \
    php8.2-intl \
    php8.2-ldap \
    php8.2-opcache \
    php8.2-apcu \
    php8.2-yaml \
    php8.2-redis \
    php8.2-tokenizer \
    php8.2-curl \
    php8.2-zip \
    composer

#RUN rm /etc/nginx/sites-enabled/default
#COPY ./default /etc/nginx/sites-enabled/
RUN chmod 777 /etc/nginx/sites-enabled/default

RUN rm /etc/nginx/nginx.conf
COPY ./nginx.conf /etc/nginx/
RUN sed -i 's/www-data/apps/g' /etc/php/8.2/fpm/pool.d/www.conf
RUN sed -i 's/listen\s=*+;/listen = \/run\/php\/php-fpm.sock/g' /etc/php/8.2/fpm/pool.d/www.conf

#RUN a2enmod rewrite

#RUN sed -i '/<Directory \/var\/www\/>/,/<\/Directory>/ s/AllowOverride None/AllowOverride All/' /etc/apache2/apache2.conf
#RUN sed -i 's/www-data/apps/g' /etc/apache2/envvars

RUN mkdir /startup
COPY ./startup.sh /startup/
RUN chmod -R 777 /startup

EXPOSE 80

CMD ["/startup/startup.sh"]
# CMD ["apache2ctl", "-D", "FOREGROUND"]
