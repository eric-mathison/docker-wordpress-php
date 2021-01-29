FROM wordpress:5.6-fpm

RUN set -ex; \
    pecl install redis \
    && echo "extenstion=redis.so" > /usr/local/etc/php/conf.d/redis.ini \
    && docker-php-ext-enable redis

COPY wordpress.ini /usr/local/etc/php/conf.d/wordpress.ini