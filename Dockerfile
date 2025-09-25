FROM nginx:1.29-alpine3.22
LABEL maintainer="Deokgyu Yang <secugyu@gmail.com>" \
      description="Lightweight h5ai 0.30.0 container with Nginx 1.29 & PHP 8.4 based on Alpine Linux."

RUN apk update
RUN apk add --no-cache \
    bash bash-completion supervisor tzdata shadow \
    php84 php84-fpm php84-session php84-json php84-xml php84-mbstring php84-exif \
    php84-intl php84-gd php84-zip php84-opcache ffmpeg \
    imagemagick zip apache2-utils patch
RUN apk add --repository=https://dl-cdn.alpinelinux.org/alpine/edge/community \
    php84-pecl-imagick

# Environments
ENV PUID=911
ENV PGID=911
ENV TZ='Asia/Seoul'
ENV HTPASSWD='false'
ENV HTPASSWD_USER='guest'
ENV HTPASSWD_PW=''

# Copy configuration files
COPY config/h5ai.conf /etc/nginx/conf.d/h5ai.conf
COPY config/php_set_timezone.ini /etc/php84/conf.d/00_timezone.ini
COPY config/php_set_jit.ini /etc/php84/conf.d/00_jit.ini
COPY config/php_set_memory_limit.ini /etc/php84/conf.d/00_memlimit.ini
COPY config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Copy h5ai
COPY config/_h5ai /usr/share/h5ai/_h5ai

# Configure Nginx server
RUN sed --in-place=.bak 's/worker_processes  1/worker_processes  auto/g' /etc/nginx/nginx.conf
RUN mv /etc/nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf.bak

# Add shell script, patch files
ADD config/init.sh /
ADD config/h5ai.conf.htpasswd.patch /
# Set entry point file permission
RUN chmod a+x /init.sh

EXPOSE 80
VOLUME [ "/config", "/h5ai" ]
ENTRYPOINT [ "/init.sh" ]
