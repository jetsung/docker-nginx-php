#!/bin/sh
#########################################################################
# Add PHP Extension
# File Name: extension.sh
# Author: Skiychan
# Email:  dev@skiy.net
# Version:
# Created Time: 2016/08/03
#########################################################################

#Add extension xdebug
curl -Lk https://pecl.php.net/get/xdebug-2.6.0.tgz | gunzip | tar x -C /home/extension && \
#curl -Lk http://127.0.0.1/tmp/xdebug-2.6.0.tgz | gunzip | tar x -C /home/extension && \
cd /home/extension/xdebug-xdebug-2.6.0 && \
/usr/local/php/bin/phpize && \
./configure --enable-xdebug --with-php-config=/usr/local/php/bin/php-config && \
make && make install

#Add extension mongodb
curl -Lk https://pecl.php.net/get/mongodb-1.4.2.tgz | gunzip | tar x -C /home/extension && \
#curl -Lk http://127.0.0.1/tmp/mongodb-1.4.2.tgz | gunzip | tar x -C /home/extension && \
cd /home/extension/mongodb-1.4.2 && \
/usr/local/php/bin/phpize && \
./configure --with-php-config=/usr/local/php/bin/php-config && \
make && make install