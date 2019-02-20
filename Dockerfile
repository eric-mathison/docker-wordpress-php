FROM alpine:3.7 AS build

RUN apk add unzip wget openssl ca-certificates

WORKDIR /root

RUN mkdir plugins
RUN cd plugins && \
  wget --content-disposition https://github.com/eric-mathison/docker-wordpress-php/blob/master/files/advanced-custom-fields-pro.zip?raw=true && \
  wget --content-disposition https://github.com/eric-mathison/docker-wordpress-php/blob/master/files/astra-addon-plugin-1.6.13.zip?raw=true && \
  wget --content-disposition https://github.com/eric-mathison/docker-wordpress-php/blob/master/files/astra-premium-sites-2.zip?raw=true && \
  wget --content-disposition https://github.com/eric-mathison/docker-wordpress-php/blob/master/files/elementor-pro-2.4.4.zip?raw=true && \
  wget --content-disposition https://github.com/eric-mathison/docker-wordpress-php/blob/master/files/ultimate-elementor.zip?raw=true && \
  wget --content-disposition https://github.com/eric-mathison/docker-wordpress-php/blob/master/files/wp-schema-pro.zip?raw=true && \
  wget https://downloads.wordpress.org/plugin/wp-mail-smtp.1.4.1.zip && \
  wget https://downloads.wordpress.org/plugin/wordpress-seo.9.6.zip && \
  wget https://downloads.wordpress.org/plugin/redirection.3.7.3.zip && \
  wget https://downloads.wordpress.org/plugin/ultimate-addons-for-gutenberg.1.9.0.zip && \
  wget https://downloads.wordpress.org/plugin/elementor.2.4.6.zip && \
  wget https://downloads.wordpress.org/plugin/redis-cache.1.4.1.zip && \
  wget https://downloads.wordpress.org/plugin/nginx-cache.1.0.4.zip && \
  wget https://downloads.wordpress.org/plugin/limit-login-attempts-reloaded.2.7.3.zip && \
  wget https://downloads.wordpress.org/plugin/autoptimize.2.4.4.zip && \
  unzip -q "*.zip" && \
  rm *.zip

RUN mkdir themes
RUN cd themes && \
  wget --content-disposition https://github.com/eric-mathison/docker-wordpress-php/blob/master/files/astra.1.6.8.zip?raw=true && \
  wget --content-disposition https://github.com/eric-mathison/docker-wordpress-php/blob/master/files/astra-child-theme.zip?raw=true && \
  unzip -q "*.zip" && \
  rm *.zip

FROM php:7.2-fpm

RUN set -ex; \
  apt-get update; \
  apt-get install -y --no-install-recommends \ 
    mysql-client \
  ;

# install the PHP extensions we need
RUN set -ex; \
	\
	savedAptMark="$(apt-mark showmanual)"; \
	\
	apt-get update; \
	apt-get install -y --no-install-recommends \
		libjpeg-dev \
		libpng-dev \
	; \
	\
	docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr; \
	docker-php-ext-install gd mysqli opcache zip; \
	\
# reset apt-mark's "manual" list so that "purge --auto-remove" will remove all build dependencies
	apt-mark auto '.*' > /dev/null; \
	apt-mark manual $savedAptMark; \
	ldd "$(php -r 'echo ini_get("extension_dir");')"/*.so \
		| awk '/=>/ { print $3 }' \
		| sort -u \
		| xargs -r dpkg-query -S \
		| cut -d: -f1 \
		| sort -u \
		| xargs -rt apt-mark manual; \
	\
	apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
	rm -rf /var/lib/apt/lists/*

# set recommended PHP.ini settings
# see https://secure.php.net/manual/en/opcache.installation.php
RUN { \
		echo 'opcache.memory_consumption=128'; \
		echo 'opcache.interned_strings_buffer=8'; \
		echo 'opcache.max_accelerated_files=4000'; \
		echo 'opcache.revalidate_freq=2'; \
		echo 'opcache.fast_shutdown=1'; \
		echo 'opcache.enable_cli=1'; \
	} > /usr/local/etc/php/conf.d/opcache-recommended.ini

RUN { \
    echo 'pm.status_path = /status'; \
    echo 'ping.path = /ping'; \
  } > /usr/local/etc/php-fpm.d/metrics.conf

COPY wordpress.ini /usr/local/etc/php/conf.d/wordpress.ini

VOLUME /var/www/html

ENV WORDPRESS_VERSION 5.0.3
ENV WORDPRESS_SHA1 f9a4b482288b5be7a71e9f3dc9b5b0c1f881102b

RUN set -ex; \
	curl -o wordpress.tar.gz -fSL "https://wordpress.org/wordpress-${WORDPRESS_VERSION}.tar.gz"; \
	echo "$WORDPRESS_SHA1 *wordpress.tar.gz" | sha1sum -c -; \
# upstream tarballs include ./wordpress/ so this gives us /usr/src/wordpress
	tar -xzf wordpress.tar.gz -C /usr/src/; \
	rm wordpress.tar.gz; \
	chown -R www-data:www-data /usr/src/wordpress

COPY --from=build /root/plugins /usr/src/plugins/
RUN chown -R www-data:www-data /usr/src/plugins
COPY --from=build /root/themes /usr/src/themes/
RUN chown -R www-data:www-data /usr/src/themes

COPY docker-entrypoint.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["php-fpm"]