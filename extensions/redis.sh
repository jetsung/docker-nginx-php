#!/bin/bash

install_redis() {
    curl -Lk https://pecl.php.net/get/redis-5.3.5.tgz | gunzip | tar x
    cd redis-5.3.5 || exit

    phpize
    ./configure --with-php-config=/usr/local/php/bin/php-config
    make && make install

    EXTENSION_DIR=$(php-config --extension-dir)
    if [ -f "$EXTENSION_DIR/redis.so" ]; then
        echo 'extension=redis.so' >/usr/local/php/etc/php.d/05-redis.ini
    fi
}

[ -d "/tmp/extension" ] || mkdir /tmp/extension

pushd /tmp/extension || exit
UNINSTALLED=$(php --ri redis | grep 'not present')
[ -z "$UNINSTALLED" ] || install_redis
popd || exit
