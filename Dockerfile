FROM composer:2 AS vendor

WORKDIR /app

COPY composer.json composer.lock ./

RUN composer install --no-dev --prefer-dist --no-scripts --optimize-autoloader

COPY . .

RUN composer run-script post-autoload-dump || true


FROM nginx:1.27-alpine

RUN apk add --no-cache \
      php83 php83-fpm \
      php83-pdo php83-pdo_mysql \
      php83-mbstring php83-zip php83-intl php83-gd php83-opcache \
      supervisor icu-data-full && \
    mkdir -p /run/php /var/log/supervisor

WORKDIR /var/www/html

COPY --from=vendor /app /var/www/html

COPY .infra/nginx.conf /etc/nginx/nginx.conf
COPY .infra/php-fpm.conf /etc/php83/php-fpm.d/www.conf
COPY .infra/supervisord.conf /etc/supervisord.conf

RUN mkdir -p storage bootstrap/cache && \
    chown -R nginx:nginx storage bootstrap/cache && \
    chmod -R 775 storage bootstrap/cache

EXPOSE 80
CMD ["supervisord","-c","/etc/supervisord.conf"]