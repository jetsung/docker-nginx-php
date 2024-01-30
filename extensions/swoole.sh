#!/bin/bash

install_swoole() {
    curl -Lk https://ghproxy.com/https://github.com/swoole/swoole-src/archive/v4.8.13.tar.gz | gunzip | tar x
    cd swoole-src-4.8.13 || exit

    phpize
    ./configure --with-php-config=/usr/local/php/bin/php-config
    make && make install

    EXTENSION_DIR=$(php-config --extension-dir)
    if [ -f "$EXTENSION_DIR/swoole.so" ]; then
        echo 'extension=swoole.so' >/usr/local/php/etc/php.d/03-swoole.ini
    fi
}

[ -d "/tmp/extension" ] || mkdir /tmp/extension

pushd /tmp/extension || exit
UNINSTALLED=$(php --ri swoole | grep 'not present')
[ -z "$UNINSTALLED" ] || install_swoole
popd || exit
