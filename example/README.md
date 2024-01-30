## Example

```bash
cd example

docker run -p 8080:80 \
-p 8443:443 \
-v $(pwd)/wwwroot:/data/wwwroot \
-v $(pwd)/wwwlogs:/data/wwwlogs \
-v $(pwd)/vhost:/usr/local/nginx/conf/vhost \
-v $(pwd)/ssl:/usr/local/nginx/conf/ssl
-v $(pwd)/extension.sh:/app/extension.sh \
-d jetsung/nginx-php:latest
```

### WEB

- **HTTP**: http://127.0.0.1:8080
- **HTTPS**: https://127.0.0.1:8443

If you modify the hosts, you can open the website with the domain.

- https://docker.222029.xyz:8443

```bash
echo '0.0.0.0 docker.222029.xyz' >> /etc/hosts
```
