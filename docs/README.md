This example is based on the source code:  
[https://github.com/jetsung/docker-nginx-php/tree/main/example](https://github.com/jetsung/docker-nginx-php/tree/main/example)

English | [简体中文](./README_CN.md)

### Include extensions

```bash
bcmath,Core,ctype,curl,date,dom,exif,fileinfo,filter,ftp,gd,gettext,hash,iconv,intl,json,libxml,mbstring,mysqli,mysqlnd,openssl,pcntl,pcre,PDO,pdo_mysql,pdo_pgsql,pdo_sqlite,pgsql,Phar,posix,redis,Reflection,session,shmop,SimpleXML,soap,sockets,sodium,SPL,sqlite3,standard,sysvsem,tokenizer,xml,xmlreader,xmlwriter,xsl,zip,zlib
```

> [Custom extension](#custom-extension)

### Container Hub

1. **[Docker Hub: `nginx-php`](https://hub.docker.com/r/jetsung/nginx-php)**

```bash
docker pull jetsung/nginx-php:latest
```

2. **[GitHub Packages: `nginx-php`](https://github.com/jetsung/docker-nginx-php/pkgs/container/nginx-php)**

```bash
docker pull ghcr.io/jetsung/nginx-php:latest
```

### Command line tools

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

### Default

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

### Custom website directory

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

### Bind the domain and the `SSL` certificate, make it to support `HTTPS`.

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

### Custom extension

```
docker run -d -p 38084:80 \
-v $(pwd)/wwwroot:/data/wwwroot \
-v $(pwd)/wwwlogs:/data/wwwlogs \
-v $(pwd)/extension.sh:/app/extension.sh \
jetsung/nginx-php
```

> Create a file `extension.sh` (you cannot change the file name)，context as [swoole](https://github.com/jetsung/docker-nginx-php/blob/main/extensions/swoole.sh)

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
