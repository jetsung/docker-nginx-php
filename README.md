Nginx and PHP for Docker

## Version
nginx: **1.9.9**   
php:   **7.0.0**

## Installation
Pull the image from the docker index rather than downloading the git repo. This prevents you having to build the image on every docker host.
```sh
docker pull skiychan/nginx-php7:latest
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

## Author
@autuor: Skiychan <dev@skiy.net>      
@link:   http://www.zzzzy.com
