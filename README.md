Nginx and PHP for Docker

## Last Version
nginx: **1.11.6**   
php:   **7.1.0**

## Docker Hub   
**Nginx-PHP7:** [https://hub.docker.com/r/skiychan/nginx-php7](https://hub.docker.com/r/skiychan/nginx-php7)   
   
## Installation
Pull the image from the docker index rather than downloading the git repo. This prevents you having to build the image on every docker host.
```sh
docker pull skiychan/nginx-php7:latest
```

To pull the Nightly Version:   
```
docker pull skiychan/nginx-php7:nightly
```

## Running
To simply run the container:
```sh
docker run --name nginx -p 8080:80 -d skiychan/nginx-php7
```
You can then browse to http://\<docker_host\>:8080 to view the default install files.

## Volumes
If you want to link to your web site directory on the docker host to the container run:
```sh
docker run --name nginx -p 8080:80 -v /your_code_directory:/data/www -d skiychan/nginx-php7
```

## Enabling SSL
```sh
docker run -d --name=nginx \
-p 80:80 -p 443:443 \
-v your_crt_key_files:/usr/local/nginx/conf/ssl \
-e PROXY_WEB=On \
-e PROXY_CRT=your_crt_name \
-e PROXY_KEY=your_key_name \
-e PROXY_DOMAIN=your_domain \
skiychan/nginx-php7
```

## Enabling Extensions With *.so
Add xxx.ini to folder ```/your_php_extension_ini``` and add xxx.so to folder ```/your_php_extension_file```, then run the command:   
```sh
docker run --name nginx \
-p 8080:80 -d \
-v /your_php_extension_ini:/usr/local/php/etc/php.d \
-v /your_php_extension_file:/data/phpext \
skiychan/nginx-php7
```
in xxx.ini, "zend_extension = /data/phpext/xxx.so", the zend_extension must be use ```/data/phpext/```.   

## Enabling Extensions With Source
Also, You can add the source to ```extension.sh```. Example:   
```
#Add extension mongodb
curl -Lk https://pecl.php.net/get/mongodb-1.1.8.tgz | gunzip | tar x -C /home/extension && \
cd /home/extension/mongodb-1.1.8 && \
/usr/local/php/bin/phpize && \
./configure --with-php-config=/usr/local/php/bin/php-config && \
make && make install
```
Add ```mongodb.ini``` to folder ```extini```:   
```
extension=mongodb.so
```

You can see the **[wiki](https://github.com/skiy-dockerfile/nginx-php7/wiki/Question-&-Answer)**

## [ChangeLog](changelogs.md)

## Thanks
[Legion](https://www.dwhd.org)  

## Author
Author: Skiychan    
Email:  dev@skiy.net       
Link:   https://www.skiy.net
