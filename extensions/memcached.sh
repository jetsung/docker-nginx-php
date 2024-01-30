#!/bin/bash

install_pecl_memcached() {
    apt-get install -y libmemcached-dev

    curl -Lk https://pecl.php.net/get/memcached-3.1.5.tgz | gunzip | tar x
    cd memcached-3.1.5 || exit

    phpize
    ./configure --with-php-config=/usr/local/php/bin/php-config
    make && make install

    EXTENSION_DIR=$(php-config --extension-dir)
    if [ -f "$EXTENSION_DIR/memcached.so" ]; then
        echo 'extension=memcached.so' >/usr/local/php/etc/php.d/05-memcached.ini
    fi

    cd ..
}

install_pecl_memcache() {
    curl -Lk https://pecl.php.net/get/memcache-8.0.tgz | gunzip | tar x
    cd memcache-8.0 || exit

    phpize
    ./configure --with-php-config=/usr/local/php/bin/php-config
    make && make install

    EXTENSION_DIR=$(php-config --extension-dir)
    if [ -f "$EXTENSION_DIR/memcache.so" ]; then
        echo 'extension=memcache.so' >/usr/local/php/etc/php.d/05-memcache.ini
    fi

    cd ..
}

[ -d "/tmp/extension" ] || mkdir /tmp/extension

pushd /tmp/extension || exit
UNINSTALLED=$(php --ri memcache | grep 'not present')
[ -z "$UNINSTALLED" ] || install_pecl_memcache

UNINSTALLED=$(php --ri memcached | grep 'not present')
[ -z "$UNINSTALLED" ] || install_pecl_memcached
popd || exit
