#!/bin/bash

# Check if setup has been completed
echo "Checking if startup tasks have been completed"

cd /var/www/html

if [ ! -f "/persist/completed.txt" ]; then
	find . -mindepth 1 -delete

	git clone -b master https://github.com/getgrav/grav.git .

	composer install --no-interaction --no-dev -o
	bin/grav install --no-interaction
	bin/gpm install -y admin

	chown -R apps:apps /var/www/html

	# Mark as completed
	touch /persist/completed.txt
	echo "Startup is complete"
else
	echo "Startup has already happened"
fi

# Configure webserver
cat webserver-configs/nginx.conf > /etc/nginx/sites-available/default
sed -i 's/server\_name.\+;$/server_name _;/g' /etc/nginx/sites-available/default
sed -i 's/root\s.\+;$/root \/var\/www\/html;/g' /etc/nginx/sites-available/default

# Configure php
sed -i 's/php8\.2\-fpm\.sock/php-fpm.sock/g' /etc/php/8.2/fpm/pool.d/www.conf
sed -i 's/upload\_max\_filesize.\+$/upload_max_filesize = 1G/g' /etc/php/8.2/fpm/php.ini
sed -i 's/post\_max\_size.\+$/post_max_size = 1G/g' /etc/php/8.2/fpm/php.ini
sed -i 's/memory\_limit.\+$/memory_limit = 2G/g' /etc/php/8.2/fpm/php.ini

#Start php-fpm and nginx
service php8.2-fpm start
nginx
