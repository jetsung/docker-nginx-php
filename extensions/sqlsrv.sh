#!/bin/bash

# 安装 PIE (PHP Installer for Extensions), 替代已弃用的 PECL
install_pie() {
    command -v pie >/dev/null 2>&1 && return

    curl -fL --retry 3 https://github.com/php/pie/releases/latest/download/pie.phar \
        -o /usr/local/bin/pie
    chmod +x /usr/local/bin/pie
}

install_pdo_sqlsrv() {
  apt install -y unixodbc-dev

  install_pie
  pie install microsoft/pdo_sqlsrv
}

[ -d "/tmp/extension" ] || mkdir /tmp/extension

pushd /tmp/extension || exit
UNINSTALLED=$(php --ri pdo_sqlsrv | grep 'not present')
[ -z "$UNINSTALLED" ] || install_pdo_sqlsrv
popd || exit