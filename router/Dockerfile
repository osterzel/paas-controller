#
# Nginx Dockerfile
#
# https://github.com/mimosa/docker-tengine
#

# Pull base image.
FROM ubuntu
MAINTAINER Howl王 <howl.wong@gmail.com>

# Let the conatiner know that there is no tty
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update -qq

# Basic Requirements
RUN apt-get -fy install python-pip python-virtualenv

# Create Nginx user
RUN adduser --disabled-login --gecos 'Tengine' nginx 

# Install Tengine Shell
WORKDIR /home/nginx
COPY tengine_2.1.0-1_amd64.deb /home/nginx/

RUN dpkg -i tengine_2.1.0-1_amd64.deb

# Define mountable directories.
#VOLUME ["/data", "/etc/nginx/sites-enabled", "/var/log/nginx"]

# 
#RUN echo "\ndaemon off;" >> /etc/nginx/nginx.conf
RUN mkdir /app
ADD requirements.txt /app/
RUN pip install -r /app/requirements.txt 
ADD . /app/

ADD conf/nginx.conf /etc/nginx/
ADD conf/default.conf /etc/nginx/conf.d/
ADD conf/index.html /etc/nginx/html/
ADD conf/404.html /etc/nginx/html/
ADD conf/50x.html /etc/nginx/html/

# Define working directory.
WORKDIR /app

ENV PATH /app:$PATH

# Define default command.
CMD ["/app/bin/app"]

# Expose ports.
EXPOSE 80
EXPOSE 443
EXPOSE 8000
