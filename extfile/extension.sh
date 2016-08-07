#!/bin/sh
#########################################################################
# File Name: extension.sh
# Author: Skiychan
# Email:  dev@skiy.net
# Version:
# Created Time: 2016/08/03
#########################################################################

#Add extension xdebug
curl -Lk https://github.com/xdebug/xdebug/archive/XDEBUG_2_4_0RC3.tar.gz | gunzip | tar x -C /home/extension && \
cd /home/extension/xdebug-XDEBUG_2_4_0RC3 && \
/usr/local/php/bin/phpize && \
./configure --enable-xdebug --with-php-config=/usr/local/php/bin/php-config && \
make && make install

#Add extension mongodb
curl -Lk https://pecl.php.net/get/mongodb-1.1.8.tgz | gunzip | tar x -C /home/extension && \
cd /home/extension/mongodb-1.1.8 && \
/usr/local/php/bin/phpize && \
./configure --with-php-config=/usr/local/php/bin/php-config && \
make && make install