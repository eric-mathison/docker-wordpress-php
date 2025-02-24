FROM wordpress:6.7-fpm

RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp \
    && rm -rf /usr/local/share/wp-cli/

RUN { \
    echo 'pm.status_path = /status'; \
    echo 'ping.path = /ping'; \
  } > /usr/local/etc/php-fpm.d/metrics.conf

COPY wordpress.ini /usr/local/etc/php/conf.d/wordpress.ini

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["php-fpm"]