#!/bin/bash

install_opcache() {
    PHP_VER=$(php-config --version)
    [ -d "php-$PHP_VER" ] || curl -Lk https://secure.php.net/distributions/php-"${PHP_VER}".tar.gz | gunzip | tar x
    cd "php-$PHP_VER/ext/opcache" || exit

    phpize
    ./configure --with-php-config=/usr/local/php/bin/php-config
    make && make install

    EXTENSION_DIR=$(php-config --extension-dir)
    if [ -f "$EXTENSION_DIR/opcache.so" ]; then
        tee /usr/local/php/etc/php.d/08-opcache.ini <<-'EOF'
[Zend Opcache]
zend_extension=opcache.so
opcache.enable = 1
opcache.memory_consumption=128
opcache.interned_strings_buffer=8
opcache.max_accelerated_files=4000
opcache.revalidate_freq=60
opcache.enable_cli=1
EOF
    fi
}

[ -d "/tmp/extension" ] || mkdir /tmp/extension

pushd /tmp/extension || exit
UNINSTALLED=$(php --rz "Zend OPcache" | grep 'does not exist')
[ -z "$UNINSTALLED" ] || install_opcache
popd || exit
