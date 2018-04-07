### 正常启动，使用默认的 ```index.php``` 文件
```
docker run --name nginx -p 38080:80 -d skiychan/nginx-php7
```
http://104.128.69.241:38080

------

### 使用指定的目录作为网站访问目录
```
docker run --name nginx1 -p 38081:80 -v /data/www:/data/www -d skiychan/nginx-php7
```
http://104.128.69.241:38081

------

### 使用 ```SSL``` 证书，让网站支持 ```HTTPS```
```
docker run -d --name=nginx2 -p 443:443 -v /data/www:/data/www -v /data/ssl:/usr/local/nginx/conf/ssl -e PROXY_WEB=On -e PROXY_CRT=fullchain.cer -e PROXY_KEY=wesay.cc.key -e PROXY_DOMAIN=1803191.wesay.cc skiychan/nginx-php7
```
将证书复制到 ```/data/ssl```目录下。   
使用宿主的 ```443```端口暴露则:         
https://1803191.wesay.cc

------

如果不使用 ```443```暴露端口，比如：   
```
docker run -d --name=nginx3 -p 38083:443 -v /data/us1:/data/www -v /data/ssl:/usr/local/nginx/conf/ssl -e PROXY_WEB=On -e PROXY_CRT=fullchain.cer -e PROXY_KEY=wesay.cc.key -e PROXY_DOMAIN=1803192.wesay.cc skiychan/nginx-php7
```
那么访问 ```https```时，必须添加端口如：      
https://1803192.wesay.cc:38083   

------

### 自定义扩展
```
docker run --name nginx4 -p 38084:80 -d -v /data/www:/data/www -v /data/extini:/data/phpextini -v /data/extshell:/data/phpextfile skiychan/nginx-php7
```
1. 在 ```/data/extini/``` 下创建文件 ```ext-swoole.ini``` ，内容为 ```extension=swoole.so```;   
2. 在 ```/data/extshell/``` 下创建文件 ```extension.sh```(不能更改文件名)，内容如下：   
```
curl -Lk https://github.com/swoole/swoole-src/archive/v2.1.1.tar.gz | gunzip | tar x -C /home/extension && \
cd /home/extension/swoole-src-2.1.1 && \
/usr/local/php/bin/phpize && \
./configure --with-php-config=/usr/local/php/bin/php-config && \
make && make install
```
http://104.128.69.241:38084
