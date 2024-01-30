#!/bin/bash

install_imap() {
    apt-get install -y libc-client-dev libkrb5-dev

    PHP_VER=$(php-config --version)
    [ -d "php-${PHP_VER}" ] || curl -Lk https://secure.php.net/distributions/php-"${PHP_VER}".tar.gz | gunzip | tar x
    cd "php-$PHP_VER/ext/imap" || exit

    phpize
    ./configure --with-php-config=/usr/local/php/bin/php-config --with-kerberos --with-imap --with-imap-ssl
    make && make install

    EXTENSION_DIR=$(php-config --extension-dir)
    if [ -f "$EXTENSION_DIR/imap.so" ]; then
        echo 'extension=imap.so' >/usr/local/php/etc/php.d/04-imap.ini
    fi
}

[ -d "/tmp/extension" ] || mkdir /tmp/extension

pushd /tmp/extension || exit
UNINSTALLED=$(php --ri imap | grep 'not present')
[ -z "$UNINSTALLED" ] || install_imap
popd || exit
