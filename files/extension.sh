#!/bin/sh
#########################################################################
# File Name: extension.sh
# Author: Skiychan
# Email:  dev@skiy.net
# Version:
# Created Time: 2016/08/03
#########################################################################

RUN mkdir -p /home/extension 

#Add extension xdebug
cd /home/extension && \
curl -O -SL https://github.com/xdebug/xdebug/archive/XDEBUG_2_4_0RC3.tar.gz && \
tar -zxvf XDEBUG_2_4_0RC3.tar.gz && \
cd xdebug-XDEBUG_2_4_0RC3 && \
/usr/local/php/bin/phpize && \
./configure --enable-xdebug --with-php-config=/usr/local/php/bin/php-config && \
make && \
cp modules/xdebug.so /usr/local/php/lib/php/extensions/no-debug-non-zts-20151012/