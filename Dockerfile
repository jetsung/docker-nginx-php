FROM ubuntu:24.04
LABEL maintainer="Jetsung Chan<jetsungchan@gmail.com>"
ARG NGINX_VERSION=1.26.2
ARG PHP_VERSION=8.4.1
ENV NGX_WWW_ROOT /data/wwwroot
ENV NGX_LOG_ROOT /data/wwwlogs
ENV TMP /tmp/nginx-php/
ENV DEBIAN_FRONTEND noninteractive
RUN mkdir -p /data/{wwwroot,wwwlogs,}
RUN set -eux \
  ; \
  apt-get update -y ; \
  pkgList="apt-utils zlib1g zlib1g-dev openssl libsqlite3-dev libxml2 libxml2-dev libcurl3-gnutls libcurl4-gnutls-dev libcurl4-openssl-dev libpng-dev libjpeg8 libjpeg8-dev libargon2-1 libargon2-dev libicu-dev libxslt1-dev libzip-dev libssl-dev libfreetype-dev libfreetype6 libpq-dev libpq5 libpcre3 libpcre3-dev libsodium-dev" ; \
  for Package in ${pkgList}; do \
  apt-get install -y --no-install-recommends ${Package} ; \
  done ; \
  apt-get install -y --no-install-recommends \
  ca-certificates \
  gcc \
  g++ \
  make \
  cmake \
  autoconf \
  pkg-config \
  libtool \
  apt-utils \
  curl \
  supervisor ; \
  mkdir -p "${TMP}" && cd "${TMP}" ; \
  curl -Lk --retry 3 "https://github.com/kkos/oniguruma/releases/download/v6.9.9/onig-6.9.9.tar.gz" | gunzip | tar x \
  ; \
  # curl -Lk --retry 3 "https://github.com/jedisct1/libsodium/releases/download/1.0.18-RELEASE/libsodium-1.0.18.tar.gz" | gunzip | tar x \
  # curl -Lk --retry 3 "https://download.libsodium.org/libsodium/releases/libsodium-1.0.18.tar.gz" | gunzip | tar x \
  # ; \
  curl -Lk --retry 3 https://pecl.php.net/get/redis-6.1.0.tgz | gunzip | tar x \
  ; \
  curl -Lk --retry 3 "https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz" | gunzip | tar x \
  ; \
  curl -Lk --retry 3 "https://php.net/distributions/php-${PHP_VERSION}.tar.gz" | gunzip | tar x \
  ; \
  cd onig-6.9.9 ; \
  ./configure --prefix=/usr ; \
  make && make install ; \
  # cd .. ; \
  # cd libsodium-1.0.18 ; \
  #   ./configure --disable-dependency-tracking --enable-minimal ; \
  #   make && make install ; \
  cd .. ; \
  cd "php-${PHP_VERSION}" ; \  
  export PKG_CONFIG_PATH=/usr/lib/x86_64-linux-gnu/pkgconfig/ ; \
  ./configure --prefix=/usr/local/php/ \
  --with-config-file-path=/usr/local/php/etc/ \
  --with-config-file-scan-dir=/usr/local/php/etc/php.d/ \
  --with-fpm-user=www \
  --with-fpm-group=www \
  --with-mysqli=mysqlnd \
  --with-pdo-mysql=mysqlnd \
  --with-pgsql \
  --with-pdo-pgsql \
  --with-zip=/usr/local \
  --with-sodium \
  --with-openssl \
  --with-iconv \
  --with-zlib \
  --with-gettext \
  --with-curl \
  --with-freetype \
  --with-jpeg \
  --with-mhash \
  --with-xsl \
  --with-password-argon2 \
  --enable-fpm \
  --enable-xml \
  --enable-shmop \
  --enable-sysvsem \
  --enable-mbregex \
  --enable-mbstring \
  --enable-ftp \
  --enable-mysqlnd \
  --enable-pcntl \
  --enable-sockets \
  --enable-soap \
  --enable-session \
  --enable-bcmath \
  --enable-exif \
  --enable-intl \
  --enable-fileinfo \
  --enable-gd \
  --enable-ipv6 \
  --disable-opcache \
  --disable-rpath \
  --disable-debug \
  --without-pear \
  # --enable-opcache \
  # --disable-fileinfo \
  ; \
  make && make install ; \
  mkdir /usr/local/php/etc/php.d/ ; \
  cp php.ini-production /usr/local/php/etc/php.ini ; \
  cp /usr/local/php/etc/php-fpm.conf.default /usr/local/php/etc/php-fpm.conf ; \
  cp /usr/local/php/etc/php-fpm.d/www.conf.default /usr/local/php/etc/php-fpm.d/www.conf ; \
  ln -s /usr/local/php/bin/* /bin/ ; \
  ln -s /usr/local/php/sbin/* /bin/ ; \
  cd .. ; \
  php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" ; \
  # php -r "if (hash_file('sha384', 'composer-setup.php') === '906a84df04cea2aa72f40b5f787e49f22d4c2f19492ac310e8cba5b96ac8b64115ac402c8cd292b8a03482574915d1a8') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" ; \
  php composer-setup.php ; \
  php -r "unlink('composer-setup.php');" ; \
  mv composer.phar /usr/local/bin/composer ; \
  chmod +x /usr/local/bin/composer ; \
  EXTENSION_DIR=$(php-config --extension-dir) ; \
  cd redis-6.1.0 ; \
  phpize ; \
  ./configure --with-php-config=/usr/local/php/bin/php-config ; \
  make && make install ; \
  if [ -f "${EXTENSION_DIR}/redis.so" ]; then \
  echo 'extension=redis.so' > /usr/local/php/etc/php.d/05-redis.ini ; \
  fi ; \
  cd .. ; \
  cd "nginx-${NGINX_VERSION}" ; \
  ./configure --prefix=/usr/local/nginx \
  --user=www --group=www \
  --error-log-path="${NGX_LOG_ROOT}/nginx_error.log" \
  --http-log-path="${NGX_LOG_ROOT}/nginx_access.log" \
  --pid-path=/var/run/nginx.pid \
  --with-pcre \
  --with-http_ssl_module \
  --with-http_v2_module \
  --without-mail_pop3_module \
  --without-mail_imap_module \
  --with-http_gzip_static_module \
  ; \
  make && make install ; \
  ln -s /usr/local/nginx/sbin/* /bin/ ; \
  useradd -r -s /sbin/nologin -d "${NGX_WWW_ROOT}" -m -k no www ; \
  cd / ; \
  rm -rf "${TMP}" ; \
  apt-get remove -y gcc \
  g++ \
  autoconf \
  automake \
  libtool \
  make \
  cmake \
  ; \
  apt-get autoremove -y ; \
  apt-get autoclean -y ; \
  apt-get clean -y ; \
  rm -rf /var/lib/apt/lists/* ; \
  find /var/log -type f -delete
VOLUME ["/data/wwwroot", "/data/wwwlogs"]
WORKDIR /app
EXPOSE 80 443 9000
COPY nginx.conf /usr/local/nginx/conf/
COPY vhost /usr/local/nginx/conf/vhost/
COPY www "${NGX_WWW_ROOT}"
COPY supervisord /etc/supervisor/conf.d/
COPY entrypoint.sh /app
RUN chown -R www:www "${NGX_WWW_ROOT}" ; \
  chmod +x /app/entrypoint.sh
ENTRYPOINT ["/app/entrypoint.sh"]
CMD ["-D"]
