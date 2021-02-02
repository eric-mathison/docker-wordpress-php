FROM wordpress:5.6-fpm

RUN set -ex; \
    pecl install redis \
    && echo "extenstion=redis.so" > /usr/local/etc/php/conf.d/redis.ini \
    && docker-php-ext-enable redis

RUN { \
    echo 'pm.status_path = /status'; \
    echo 'ping.path = /ping'; \
  } > /usr/local/etc/php-fpm.d/metrics.conf

COPY wordpress.ini /usr/local/etc/php/conf.d/wordpress.ini

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["php-fpm"]