#!/bin/sh
#########################################################################
# File Name: start.sh
# Author: Skiychan
# Email:  dev@skiy.net
# Version:
# Created Time: 2015/12/13
#########################################################################
PATH=/bin:/usr/local/nginx/sbin:$PATH
Nginx_Install_Dir=/usr/local/nginx
DATA_DIR=/data/www

set -e

if [ "${1:0:1}" = '-' ]; then
        set -- nginx "$@"
fi

if [[ -h /var/lock ]]; then
    rm -rf /var/lock
    [ -f /var/lock/subsys ] || mkdir -p /var/lock/subsys
    #touch /var/lock/subsys/nginx
fi

chown -R www.www $DATA_DIR

if [[ -n "$PROXY_WEB" ]]; then

    [ -f "${Nginx_Install_Dir}/conf/ssl" ] || mkdir -p $Nginx_Install_Dir/conf/ssl
    [ -f "${Nginx_Install_Dir}/conf/vhost" ] || mkdir -p $Nginx_Install_Dir/conf/vhost

    if [ -z "$PROXY_DOMAIN" ]; then
            echo >&2 'error:  missing PROXY_DOMAIN'
            echo >&2 '  Did you forget to add -e PROXY_DOMAIN=... ?'
            exit 1
    fi

    if [ -z "$PROXY_CRT" ]; then
         echo >&2 'error:  missing PROXY_CRT'
         echo >&2 '  Did you forget to add -e PROXY_CRT=... ?'
         exit 1
     fi

     if [ -z "$PROXY_KEY" ]; then
             echo >&2 'error:  missing PROXY_KEY'
             echo >&2 '  Did you forget to add -e PROXY_KEY=... ?'
             exit 1
     fi

     if [ -f "${Nginx_Install_Dir}/conf/ssl/${PROXY_CRT}" ]; then
             echo >&2 'error:  missing PROXY_CRT'
             echo >&2 "  You need to put ${PROXY_CRT} in ssl directory"
             exit 1
     fi

     if [ -f "${Nginx_Install_Dir}/conf/ssl/${PROXY_KEY}" ]; then
             echo >&2 'error:  missing PROXY_CSR'
             echo >&2 "  You need to put ${PROXY_KEY} in ssl directory"
             exit 1
     fi

    cat > ${Nginx_Install_Dir}/conf/vhost/website.conf << EOF
server {
    listen 80;
    server_name $PROXY_DOMAIN;
    return 301 https://$PROXY_DOMAIN\$request_uri;
    }

server {
    listen 443 ssl;
    server_name $PROXY_DOMAIN;

    ssl on;
    ssl_certificate ssl/${PROXY_CRT};
    ssl_certificate_key ssl/${PROXY_KEY};
    ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
    ssl_prefer_server_ciphers on;
    ssl_ciphers ALL:!aNULL:!ADH:!eNULL:!LOW:!EXP:RC4+RSA:+HIGH:+MEDIUM;
    keepalive_timeout 70;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;
}
EOF
fi

#/usr/local/php7/sbin/php-fpm
#/usr/local/nginx/sbin/nginx

/etc/init.d/php-fpm start

/etc/init.d/nginx start

#exec "$@" -g "daemon off;"
