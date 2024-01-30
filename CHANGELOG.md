# CHNAGELOG

- Since [46fa6a0](https://github.com/jetsung/docker-nginx-php/tree/46fa6a0f2621a4369e3f369ce165383a81115b61)

---

## 2022.01.22

Associated tags: `8.1.021, 8.0.151`

Include extensions:
`bcmath,Core,ctype,curl,date,dom,exif,fileinfo,filter,ftp,gd,gettext,hash,iconv,intl,json,libxml,mbstring,mysqli,mysqlnd,openssl,pcntl,pcre,PDO,pdo_mysql,pdo_pgsql,pdo_sqlite,pgsql,Phar,posix,redis,Reflection,session,shmop,SimpleXML,soap,sockets,sodium,SPL,sqlite3,standard,sysvsem,tokenizer,xml,xmlreader,xmlwriter,xsl,zip,zlib`

1. The base image replaces almalinux with `ubuntu:20.04`.
2. Add `supervisor` to the image.
3. Remove extensions: `imagick,raphf,pq`
4. Add extensions: `pdo_pgsql,pgsql`

---

## 2022.01.10

Associated tags: `8.1.013, 8.0.143, 7.4.273, 7.3, 7.2`

Include extensions:
`bcmath,Core,ctype,curl,date,dom,exif,filter,ftp,gd,gettext,hash,iconv,intl,json,libxml,mbstring,mysqli,mysqlnd,openssl,pcntl,pcre,PDO,pdo_mysql,pdo_sqlite,Phar,posix,redis,Reflection,session,shmop,SimpleXML,soap,sockets,sodium,SPL,sqlite3,standard,sysvsem,tokenizer,xml,xmlreader,xmlwriter,xsl,zip,zlib`

1.  Add extensions: `fileinfo,pq,raphf,imagick,redis`
