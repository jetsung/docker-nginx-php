#!/bin/bash

install_imagemagick() {
    curl -Lk https://ghproxy.com/https://github.com/ImageMagick/ImageMagick/archive/refs/tags/7.1.0-19.tar.gz | gunzip | tar x

    cd ImageMagick-7.1.0-19 || exit
    ./configure --prefix=/usr/local/imagemagick --enable-shared --enable-static
    make && make install

    cd ..
}

install_pecl_imagick() {
    apt-get install -y libmagickwand-dev
    # or
    # install_imagemagick

    curl -Lk https://pecl.php.net/get/imagick-3.6.0.tgz | gunzip | tar x
    cd imagick-3.6.0 || exit

    phpize
    ./configure --with-php-config=/usr/local/php/bin/php-config --with-imagick=/usr/local/imagemagick
    make && make install

    EXTENSION_DIR=$(php-config --extension-dir)
    if [ -f "$EXTENSION_DIR/imagick.so" ]; then
        echo 'extension=imagick.so' >/usr/local/php/etc/php.d/03-imagick.ini
    fi

    cd ..
}

[ -d "/tmp/extension" ] || mkdir /tmp/extension

pushd /tmp/extension || exit
UNINSTALLED=$(php --ri imagick | grep 'not present')
[ -z "$UNINSTALLED" ] || install_pecl_imagick
popd || exit
