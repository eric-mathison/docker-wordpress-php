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
  wget --content-disposition https://github.com/eric-mathison/docker-wordpress-php/blob/master/files/mathisonmedia-child-theme.zip?raw=true && \
  unzip -q "*.zip" && \
  rm *.zip

# Final Build
FROM wordpress:fpm

COPY wordpress.ini /usr/local/etc/php/conf.d/wordpress.ini

WORKDIR /var/www/html

# Install plugins
COPY --from=build /root/plugins wp-content/plugins
COPY --from=build /root/themes wp-content/themes