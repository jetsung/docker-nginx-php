FROM centos:7
MAINTAINER Skiychan <dev@skiy.net>
##
# Nginx: 1.9.9
# PHP  : 7.0.1
##
#Install system library
#RUN yum update -y
RUN yum install -y gcc \
    gcc-c++ \
    autoconf \
    automake \
    libtool \
    make \
    cmake && \
    yum clean all

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
    libpng-devel \
    libjpeg-devel \
    freetype-devel \
    libmcrypt-devel \
    openssh-server \
    python-setuptools && \
    yum clean all

#Add user
RUN groupadd -r www && \
    useradd -M -s /sbin/nologin -r -g www www

#Download nginx & php
RUN mkdir -p /home/nginx-php && cd $_ && \
    wget -c -O nginx.tar.gz http://nginx.org/download/nginx-1.9.9.tar.gz && \
    wget -O php.tar.gz http://am1.php.net/get/php-7.0.1.tar.gz/from/this/mirror

#Make install nginx
RUN cd /home/nginx-php && \
    tar -zxvf nginx.tar.gz && \
    cd nginx-1.9.9 && \
    ./configure --prefix=/usr/local/nginx \
    --user=www --group=www \
    --error-log-path=/var/log/nginx_error.log \
    --http-log-path=/var/log/nginx_access.log \
    --pid-path=/var/run/nginx.pid \
    --with-pcre \
    --with-http_ssl_module \
    --without-mail_pop3_module \
    --without-mail_imap_module \
    --with-http_gzip_static_module && \
    make && make install

#Make install php
RUN cd /home/nginx-php && \
    tar zvxf php.tar.gz && \
    cd php-7.0.1 && \
    ./configure --prefix=/usr/local/php7 \
    --with-config-file-path=/usr/local/php7/etc \
    --with-config-file-scan-dir=/usr/local/php7/etc/php.d \
    --with-fpm-user=www \
    --with-fpm-group=www \
    --with-mcrypt=/usr/include \
    --with-mysqli \
    --with-pdo-mysql \
    --with-openssl \
    --with-gd \
    --with-iconv \
    --with-zlib \
    --with-gettext \
    --with-curl \
    --with-png-dir \
    --with-jpeg-dir \
    --with-freetype-dir \
    --with-xmlrpc \
    --with-mhash \
    --enable-fpm \
    --enable-xml \
    --enable-shmop \
    --enable-sysvsem \
    --enable-inline-optimization \
    --enable-mbregex \
    --enable-mbstring \
    --enable-ftp \
    --enable-gd-native-ttf \
    --enable-mysqlnd \
    --enable-pcntl \
    --enable-sockets \
    --enable-zip \
    --enable-soap \
    --enable-session \
    --enable-opcache \
    --enable-bcmath \
    --enable-exif \
    --disable-fileinfo \
    --disable-rpath \
    --disable-ipv6 \
    --disable-debug \
    --without-pear && \
    make && make install

RUN	cd /home/nginx-php/php-7.0.1 && \
    cp php.ini-production /usr/local/php7/etc/php.ini && \
    cp /usr/local/php7/etc/php-fpm.conf.default /usr/local/php7/etc/php-fpm.conf && \
    cp /usr/local/php7/etc/php-fpm.d/www.conf.default /usr/local/php7/etc/php-fpm.d/www.conf

#Install supervisor
RUN easy_install supervisor && \
    mkdir -p /var/log/supervisor && \
    mkdir -p /var/run/sshd && \
    mkdir -p /var/run/supervisord

#Add supervisord conf
ADD supervisord.conf /etc/supervisord.conf

#Remove zips
RUN cd / && rm -rf /home/nginx-php

#Create web folder
VOLUME ["/data/www", "/usr/local/nginx/conf/ssl", "/usr/local/nginx/conf/vhost"]
ADD index.php /data/www/index.php

#Update nginx config
ADD nginx.conf /usr/local/nginx/conf/nginx.conf

#Start
ADD start.sh /start.sh
RUN chmod +x /start.sh

#Set port
EXPOSE 80 443

#ENTRYPOINT ["/start.sh"]

#Start web server
CMD ["/bin/bash", "/start.sh"]
