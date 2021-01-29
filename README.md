# Wordpress PHP-FPM with Redis Support - Docker Image

Based off the official Wordpress PHP-FPM Docker image

### PHP.ini Settings

```
memory_limit = 512M
upload_max_filesize = 200M
post_max_size = 200M
max_execution_time = 600
max_input_time = 600
```

### Docker Compose example:

```
version: "3.3"
services:
  wordpress:
    image: ericmathison/wordpress:5.6-fpm-redis
    volumes:
      - wp-data:/var/www/html
    environment:
      WORDPRESS_DB_NAME: wordpress
      WORDPRESS_DB_HOST: localhost
      WORDPRESS_DB_PASSWORD: wp_password
      WORDPRESS_DB_USER: wp_user
      ENABLE_REDIS: false
      REDIS_HOST: localhost
      REDIS_PORT: 6379
      REDIS_SALT: wordpress
    restart: always
```
