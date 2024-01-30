#!/bin/bash

install_pdo_sqlsrv() {
  apt install -y unixodbc-dev

  curl -Lk http://pecl.php.net/get/pdo_sqlsrv-5.11.0.tgz | gunzip | tar x
  cd pdo_sqlsrv-5.11.0 || exit

  phpize
  ./configure --with-php-config=/usr/local/php/bin/php-config
  make && make install

  EXTENSION_DIR=$(php-config --extension-dir)
  if [ -f "$EXTENSION_DIR/pdo_sqlsrv.so" ]; then
    echo 'extension=pdo_sqlsrv.so' >/usr/local/php/etc/php.d/02-sqlsrv.ini
  fi
}

[ -d "/tmp/extension" ] || mkdir /tmp/extension

pushd /tmp/extension || exit
UNINSTALLED=$(php --ri pdo_sqlsrv | grep 'not present')
[ -z "$UNINSTALLED" ] || install_pdo_sqlsrv
popd || exit
