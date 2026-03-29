FROM nginx:slim

ENV NGINX_PORT1=8080
ENV NGINX_PORT2=8081
ENV NGINX_PORT3=80

LABEL nginx_port1=${NGINX_PORT1}
LABEL nginx_port2=${NGINX_PORT2}
LABEL nginx_port3=${NGINX_PORT3}

RUN apt-get update && apt-get install -y curl

RUN curl --version

RUN mkdir -p /usr/share/nginx/html \
    mkdir -p /usr/share/nginx/html/app1 \
    mkdir -p /usr/share/nginx/html/app2

COPY app1/index.html /usr/share/nginx/html/app1/index.html
COPY app2/index.html /usr/share/nginx/html/app2/index.html
COPY index.html /usr/share/nginx/html/index.html

COPY error.html /usr/share/nginx/html/app1
COPY error.html /usr/share/nginx/html/app2

COPY nginx.conf /etc/nginx/conf.d/custom.conf


EXPOSE ${NGINX_PORT1} ${NGINX_PORT2} ${NGINX_PORT3}