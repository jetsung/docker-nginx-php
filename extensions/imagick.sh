#!/bin/bash

# 安装 PIE (PHP Installer for Extensions), 替代已弃用的 PECL
install_pie() {
    command -v pie >/dev/null 2>&1 && return

    curl -fL --retry 3 https://github.com/php/pie/releases/latest/download/pie.phar \
        -o /usr/local/bin/pie
    chmod +x /usr/local/bin/pie
}

install_imagemagick() {
    curl -Lk --retry 3 https://github.com/ImageMagick/ImageMagick/archive/refs/tags/7.1.2-35.tar.gz | gunzip | tar x

    cd ImageMagick-7.1.2-35 || exit
    ./configure --prefix=/usr/local/imagemagick --enable-shared --enable-static
    make && make install

    cd ..
}

install_imagick() {
    apt-get install -y libmagickwand-dev
    # or
    # install_imagemagick

    install_pie
    if [ -d /usr/local/imagemagick ]; then
        pie install imagick/imagick -- --with-imagick=/usr/local/imagemagick
    else
        pie install imagick/imagick
    fi
}

[ -d "/tmp/extension" ] || mkdir /tmp/extension

pushd /tmp/extension || exit
UNINSTALLED=$(php --ri imagick | grep 'not present')
[ -z "$UNINSTALLED" ] || install_imagick
popd || exit
