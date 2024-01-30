# Nginx and PHP for Docker

English | [简体中文](./README_CN.md)

## Version

| Name    | Version |  Docker tag  |
| :------ | :------ | :----------: |
| **PHP** | 8.3.x   | latest / 8.3 |
| **PHP** | 8.2.x   |     8.2      |
| **PHP** | 8.1.x   |     8.1      |

### EOL

| Docker tag  | PHP    | NGINX  |
| :---------- | :----- | :----: |
| **8.0.300** | 8.0.30 | 1.24.0 |

## Include extensions

```bash
bcmath,Core,ctype,curl,date,dom,exif,fileinfo,filter,ftp,gd,gettext,hash,iconv,intl,json,libxml,mbstring,mysqli,mysqlnd,openssl,pcntl,pcre,PDO,pdo_mysql,pdo_pgsql,pdo_sqlite,pgsql,Phar,posix,redis,Reflection,session,shmop,SimpleXML,soap,sockets,sodium,SPL,sqlite3,standard,sysvsem,tokenizer,xml,xmlreader,xmlwriter,xsl,zip,zlib
```

> [Custom extension](./extensions)

## Container Hub

1. **[Docker Hub: `nginx-php`](https://hub.docker.com/r/jetsung/nginx-php)**

```bash
docker pull jetsung/nginx-php:latest
```

2. **[GitHub Packages: `nginx-php`](https://github.com/jetsung/docker-nginx-php/pkgs/container/nginx-php)**

```bash
docker pull ghcr.io/jetsung/nginx-php:latest
```

## Manual

- **[WebSite](http://nginx-php.222029.xyz)**
- [Documents](./docs)
- [Extensions](./extensions)

## Build

```sh
git clone https://github.com/jetsung/docker-nginx-php.git

cd nginx-php

docker build --build-arg PHP_VERSION="8.1.1" \
  --build-arg NGINX_VERSION="1.20.0" \
  -t nginx-php:8.1 \
  -f ./Dockerfile .
```

## Installation

Pull the image from the docker index rather than downloading the git repo. This prevents you having to build the image on every docker host.

```sh
docker pull jetsung/nginx-php:latest
```

## Running

To simply run the container:

```sh
docker run --name nginx -p 8080:80 -d jetsung/nginx-php
```

You can then browse to `http://\<docker_host\>:8080` to view the default install files.

### docker-compose.yml

```yaml
version: "3"
services:
  nginx-php:
    image: jetsung/nginx-php:latest
    ports:
      - "38080:80"
```

## Command line tools

Use `docker exec {CONTAINER ID} {COMMAND}`

```bash
# Current process
docker exec {CONTAINER ID} ps -ef
# Current PHP version
docker exec {CONTAINER ID} php --version

# supervisord
## HELP
docker exec {CONTAINER ID} supervisorctl --help
## STOP, START, STATUS (stop/start/status)
docker exec {CONTAINER ID} supervisorctl stop all
## STOP NGINX / PHP
docker exec {CONTAINER ID} supervisorctl stop nginx/php-fpm

# Container not started
## PHP version
docker run --rm -it jetsung/nginx-php:latest php --version

## NGINX version
docker run --rm -it jetsung/nginx-php:latest nginx -v
```

## [CHANGELOG](./CHANGELOG.md)
