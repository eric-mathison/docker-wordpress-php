FROM alpine:3.7 AS build

RUN apk add unzip openssl ca-certificates

WORKDIR /root

RUN mkdir plugins
RUN cd plugins && \
  wget https://downloads.wordpress.org/plugin/wordpress-seo.9.6.zip && \
  unzip -q "*.zip" && \
  rm *.zip

# Final Build
FROM wordpress:fpm

COPY wordpress.ini /usr/local/etc/php/conf.d/wordpress.ini

WORKDIR /var/www/html

# Install plugins
COPY --from=build /root/plugins wp-content/plugins