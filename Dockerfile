FROM ubuntu:14.04
MAINTAINER Skiychan <dev@skiy.net>

#Install update & library
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
	libfreetype6-dev \
	supervisor

#Create folder
RUN mkdir -p /home/nginx-php7

#ADD nginx.sh /home/nginx-php7/
#ADD php-7.sh /home/nginx-php7/
#ADD download.sh /home/nginx-php7/
#ADD app.conf /home/nginx-php7/
#ADD nginx.conf /home/nginx-php7/
#ADD Nginx-init-Ubuntu /home/nginx-php7/

#Copy files to folder
COPY . /home/nginx-php7
#Make sh to run
RUN chmod +x /home/nginx-php7/*.sh

# Start Supervisord
ADD ./supervisord.conf /etc/supervisord.conf
ADD ./start.sh /start.sh
RUN chmod +x /start.sh

#Web folder
VOLUME ["/data/www"]
COPY ./index.php /data/www/index.php

#Install nginx
RUN cd /home/nginx-php7/ && \
	. ./app.conf && \
	. ./download.sh && \
	. ./nginx.sh && \
	mkdir src && \
	Install_Nginx

#Install PHP
RUN cd /home/nginx-php7/ && \
	. ./app.conf && \
	. ./download.sh && \
 	. ./php-7.sh && \
 	Install_PHP7

#Set port
EXPOSE 80

#Start web server
CMD ["/bin/bash", "/start.sh"]
