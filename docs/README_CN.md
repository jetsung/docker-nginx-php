案例基于源码:  
[https://github.com/jetsung/docker-nginx-php/tree/main/example](https://github.com/jetsung/docker-nginx-php/tree/main/example)

[English](./README.md) | 简体中文

### 包含扩展

```bash
bcmath,Core,ctype,curl,date,dom,exif,fileinfo,filter,ftp,gd,gettext,hash,iconv,intl,json,libxml,mbstring,mysqli,mysqlnd,openssl,pcntl,pcre,PDO,pdo_mysql,pdo_pgsql,pdo_sqlite,pgsql,Phar,posix,redis,Reflection,session,shmop,SimpleXML,soap,sockets,sodium,SPL,sqlite3,standard,sysvsem,tokenizer,xml,xmlreader,xmlwriter,xsl,zip,zlib
```

> [定制扩展](#定制扩展)

### Container Hub

1. **[Docker Hub: `nginx-php`](https://hub.docker.com/r/jetsung/nginx-php)**

```bash
docker pull jetsung/nginx-php:latest
```

2. **[GitHub Packages: `nginx-php`](https://github.com/jetsung/docker-nginx-php/pkgs/container/nginx-php)**

```bash
docker pull ghcr.io/jetsung/nginx-php:latest
```

### 命令行工具

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

### 默认

```
docker run -d -p 38080:80 \
jetsung/nginx-php
```

[http://docker.222029.xyz:38080](http://docker.222029.xyz:38080)

- `docker-compose.yml`

```yaml
version: "3"
services:
  nginx-php:
    image: jetsung/nginx-php:latest
    ports:
      - "38080:80"
```

---

### 自定义网站目录

```
docker run -d -p 38081:80 \
-v $(pwd)/wwwroot:/data/wwwroot \
jetsung/nginx-php
```

[http://docker.222029.xyz:38081](http://docker.222029.xyz:38081)

- `docker-compose.yml`

```yaml
version: "3"
services:
  nginx-php:
    image: jetsung/nginx-php:latest
    volumes:
      - ./wwwroot:/data/wwwroot
    ports:
      - "38081:80"
```

---

### 绑定域名 和 使用 `SSL` 证书，让网站支持 `HTTPS`

```
docker run -d -p 38082:80 \
-p 38083:443 \
-v $(pwd)/wwwroot:/data/wwwroot \
-v $(pwd)/wwwlogs:/data/wwwlogs \
-v $(pwd)/vhost:/usr/local/nginx/conf/vhost \
-v $(pwd)/ssl:/usr/local/nginx/conf/ssl \
jetsung/nginx-php
```

[http://docker.222029.xyz:38082](http://docker.222029.xyz:38082)  
[https://docker.222029.xyz:38083](https://docker.222029.xyz:38083)

- `docker-compose.yml`

```yaml
version: "3"
services:
  nginx-php:
    image: jetsung/nginx-php:latest
    volumes:
      - ./wwwroot:/data/wwwroot
      - ./wwwlogs:/data/wwwlogs
      - ./vhost:/usr/local/nginx/conf/vhost
      - ./ssl:/usr/local/nginx/conf/ssl
    ports:
      - "38082:80"
      - "38083:443"
```

---

### 定制扩展

```
docker run -d -p 38084:80 \
-v $(pwd)/wwwroot:/data/wwwroot \
-v $(pwd)/wwwlogs:/data/wwwlogs \
-v $(pwd)/extension.sh:/app/extension.sh \
jetsung/nginx-php
```

> 创建文件 `extension.sh` (不可更改文件名)，内容为 [swoole](https://github.com/jetsung/docker-nginx-php/blob/main/extensions/swoole.sh)

[http://docker.222029.xyz:38084](http://docker.222029.xyz:38084)

- `docker-compose.yml`

```yaml
version: "3"
services:
  nginx-php:
    image: jetsung/nginx-php:latest
    volumes:
      - ./wwwroot:/data/wwwroot
      - ./wwwlogs:/data/wwwlogs
      - ./extension.sh:/app/extension.sh
    ports:
      - "38084:80"
```

### [Changelog](https://github.com/jetsung/docker-nginx-php/blob/main/CHANGELOG.md)
