#!/bin/bash
#########################################################################
# START
# File Name: entrypoint.sh
# Author: Jetsung Chan
# Email:  jetsungchan@gmail.com
# Created: 2019/09/02
# Updated: 2023/03/11
#########################################################################

set -e
set -u
set -o pipefail

install_tools() {
    apt-get update -y
    apt-get install -y gcc \
        g++ \
        autoconf \
        automake \
        make \
        cmake
}

clear_tools() {
    apt-get remove -y gcc \
        g++ \
        autoconf \
        automake \
        make \
        cmake
    apt-get autoremove -y
    apt-get autoclean -y
    apt-get clean -y
}

# Add PHP Extension
install_extensions() {
    if [ -f "/app/extension.sh" ] && [ ! -f /app/.installed ]; then
        pushd /app >/dev/null || exit
        install_tools

        bash extension.sh
        date "+%F %T" >>/app/.installed

        #clear_tools
        popd >/dev/null || exit
    fi
}

if [[ "${1}" = "-D" ]]; then
    install_extensions 2>&1 | tee ./install.log

    # start supervisord and services
    exec /usr/bin/supervisord -n -c /etc/supervisor/supervisord.conf
else
    exec "$@"
fi
