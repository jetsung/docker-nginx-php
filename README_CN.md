# Nginx and PHP for Docker

[English](./README.md) | 简体中文

## 版本

| 名称    | 版本  | Docker 标签  |
| :------ | :---- | :----------: |
| **PHP** | 8.4.x | latest / 8.4 |
| **PHP** | 8.3.x |     8.3      |
| **PHP** | 8.2.x |     8.2      |
| **PHP** | 8.1.x |     8.1      |

### 终止

| Docker tag  | PHP    | NGINX  |
| :---------- | :----- | :----: |
| **8.0.300** | 8.0.30 | 1.24.0 |

## 包含扩展

```bash
bcmath,Core,ctype,curl,date,dom,exif,fileinfo,filter,ftp,gd,gettext,hash,iconv,intl,json,libxml,mbstring,mysqli,mysqlnd,openssl,pcntl,pcre,PDO,pdo_mysql,pdo_pgsql,pdo_sqlite,pgsql,Phar,posix,redis,Reflection,session,shmop,SimpleXML,soap,sockets,sodium,SPL,sqlite3,standard,sysvsem,tokenizer,xml,xmlreader,xmlwriter,xsl,zip,zlib
```

> [定制扩展](./extensions)

## Container Hub

1. **[Docker Hub: `nginx-php`](https://hub.docker.com/r/jetsung/nginx-php)**

```bash
docker pull jetsung/nginx-php:latest
```

2. **[GitHub Packages: `nginx-php`](https://github.com/jetsung/docker-nginx-php/pkgs/container/nginx-php)**

```bash
docker pull ghcr.io/jetsung/nginx-php:latest
```

## 手册

- **[网站](http://nginx-php.222029.xyz)**
- [文档](./docs)
- [扩展](./extensions)

## 构建

```sh
git clone https://github.com/jetsung/docker-nginx-php.git

cd nginx-php

docker build --build-arg PHP_VERSION="8.1.1" \
  --build-arg NGINX_VERSION="1.20.0" \
  -t nginx-php:8.1 \
  -f ./Dockerfile .
```

## 安装使用

从 Docker 拉取镜像

```sh
docker pull jetsung/nginx-php:latest
```

## 启动

使用镜像启动基础容器

```sh
docker run --name nginx -p 8080:80 -d jetsung/nginx-php
```

你可以通过浏览器访问 `http://\<docker_host\>:8080` 查看 `PHP` 配置信息。

### docker-compose.yml

```yaml
version: "3"
services:
  nginx-php:
    image: jetsung/nginx-php:latest
    ports:
      - "38080:80"
```

## 命令行工具

使用 `docker exec {CONTAINER ID} {COMMAND}`

```bash
# 查看当前进程
docker exec {CONTAINER ID} ps -ef
# 查看当前 PHP 版本
docker exec {CONTAINER ID} php --version

# supervisord
## 帮助
docker exec {CONTAINER ID} supervisorctl --help
## 停止、启动、状态 (stop/start/status)
docker exec {CONTAINER ID} supervisorctl stop all
## 停止 NGINX / PHP
docker exec {CONTAINER ID} supervisorctl stop nginx/php-fpm

# 未启动容器
## 查看 PHP 版本
docker run --rm -it jetsung/nginx-php:latest php --version

## 查看 NGINX 版本
docker run --rm -it jetsung/nginx-php:latest nginx -v
```

## [CHANGELOG](./CHANGELOG.md)
