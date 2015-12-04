FROM ubuntu:14.04
MAINTAINER Skiychan <dev@skiy.net>

RUN apt-get update && \
	apt-get install -y \
	wget \
	build-essential \
	libssl-dev \
	libxml2-dev \
	libcurl4-openssl-dev \
	pkg-config \
	libjpeg-dev \
	libpng-dev \
	libpng-dev \
	libfreetype6-dev

RUN mkdir -p /home/nginx-php7

#ADD nginx.sh /home/nginx-php7/
#ADD php-7.sh /home/nginx-php7/
#ADD download.sh /home/nginx-php7/
#ADD app.conf /home/nginx-php7/
#ADD nginx.conf /home/nginx-php7/
#ADD Nginx-init-Ubuntu /home/nginx-php7/

COPY . /home/nginx-php7

# Start Supervisord
ADD ./start.sh /start.sh
RUN chmod 755 /start.sh

VOLUME ["/data/www"]

RUN chmod +x /home/nginx-php7/*.sh

RUN cd /home/nginx-php7/ && \
	. ./app.conf && \
	. ./download.sh && \
	. ./nginx.sh && \
	mkdir src && \
	Install_Nginx
RUN cd /home/nginx-php7/ && \
	. ./app.conf && \
	. ./download.sh && \
 	. ./php-7.sh && \
 	Install_PHP7 && \

RUN cd .. && \
	rm -rf /home/nginx-php7
 
EXPOSE 80

CMD ["/bin/bash", "/start.sh"]
