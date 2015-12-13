FROM centos:7
MAINTAINER Skiychan <dev@skiy.net>

#Install system library
RUN yum -y install \
	  gcc \
		gcc-c++ \
		autoconf \
		automake \
		libtool \
		make \
		cmake

#Install PHP library
## libmcrypt-devel DIY
RUN rpm -ivh http://dl.fedoraproject.org/pub/epel/6/i386/epel-release-6-8.noarch.rpm && \
		yum install -y wget \
		zlib \
		zlib-devel \
		openssl \
		openssl-devel \
		pcre-devel \
		libxml2 \
		libxml2-devel \
		libcurl \
		libcurl-devel \
		libjpeg-devel \
		libpng-devel \
		freetype-devel \
		libmcrypt-devel && \
		yum clean all

#Download & Make install nginx
RUN cd /home && \
 		wget -c http://nginx.org/download/nginx-1.9.9.tar.gz && \
		tar -zxvf nginx-1.9.9.tar.gz && \
		cd nginx-1.9.9 && \
./configure --prefix=/usr/local/nginx --pid-path=/usr/local/nginx/run/nginx.pid --with-http_ssl_module --with-pcre --without-mail_pop3_module --without-mail_imap_module --without-mail_smtp_module && \
		make && \
		make install

RUN cd /home && \
    wget -O php-7.0.0.tar.gz http://am1.php.net/get/php-7.0.0.tar.gz/from/this/mirror && \
		tar zvxf php-7.0.0.tar.gz && \
		cd php-7.0.0 && \
./configure --prefix=/usr/local/php7 --with-config-file-path=/usr/local/php7/etc --with-config-file-scan-dir=/usr/local/php7/etc/php.d --with-mcrypt=/usr/include --enable-mysqlnd --with-mysqli --with-pdo-mysql --enable-fpm --with-fpm-user=nginx --with-fpm-group=nginx --with-gd --with-iconv --with-zlib --enable-xml --enable-shmop --enable-sysvsem --enable-inline-optimization --enable-mbregex --enable-mbstring --enable-ftp --enable-gd-native-ttf --with-openssl --enable-pcntl --enable-sockets --with-xmlrpc --enable-zip --enable-soap --without-pear --with-gettext --enable-session --with-curl --with-jpeg-dir --with-freetype-dir --enable-opcache && \
		make && \
		make install && \
		cp php.ini-production /usr/local/php7/etc/php.ini && \
		cp /usr/local/php7/etc/php-fpm.conf.default /usr/local/php7/etc/php-fpm.conf && \
		cp /usr/local/php7/etc/php-fpm.d/www.conf.default /usr/local/php7/etc/php-fpm.d/www.conf

#Remove zips
#RUN cd / && rm -rf /home/*

#Create web folder
RUN mkdir -p /data/www
VOLUME ["/data/www"]
ADD ./index.php /data/www/index.php
#RUN chown -Rf www-data.www-data /data/www

#Update nginx config
#ADD ./nginx.conf /usr/local/nginx/conf/nginx.conf
#RUN sed -i -e"s/worker_processes  1/worker_processes 5/" /usr/local/nginx/conf/nginx.conf && \
#sed -i -e"s/keepalive_timeout\s*65/keepalive_timeout 2/" /usr/local/nginx/conf/nginx.conf && \
#sed -i -e"s/keepalive_timeout 2/keepalive_timeout 2;\n\tclient_max_body_size 100m/" /usr/local/nginx/conf/nginx.conf && \
#echo "daemon off;" >> /usr/local/nginx/conf/nginx.conf

#Start
ADD ./start.sh /start.sh
RUN chmod +x /start.sh

#Set port
EXPOSE 80

#Start web server
CMD ["/bin/bash", "/start.sh"]
