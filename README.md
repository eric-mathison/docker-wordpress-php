PHP Docker Image for use with [Wordpress-NGINX Image](https://github.com/eric-mathison/docker-wordpress-nginx)

### PHP.ini Settings
```
memory_limit =512M
upload_max_filesize = 200M
post_max_size = 200M
max_execution_time = 500
max_input_time = 500
```

docker-compose example:
```
version: "3"
services: 
  db:
    image: mariadb:10.3
    container_name: mysql
    ports: 
      - '3306:3306'
    volumes: 
      - db_data:/var/lib/mysql
    environment: 
      - MYSQL_ROOT_PASSWORD=password
      - MYSQL_USER=wp_user
      - MYSQL_PASSWORD=wp_password
      - MYSQL_DATABASE=wordpress
    restart: always
  
  wordpress:
    image: ericmathison/wordpress-php:latest
    container_name: wordpress
    depends_on:
      - db
    ports: 
      - '9000:9000'
    volumes:
      - wp_data:/var/www/html
      - wp_cache:/var/cache/nginxfastcgi
    environment: 
      - WORDPRESS_DB_NAME=wordpress
      - WORDPRESS_TABLE_PREFIX=wp_
      - WORDPRESS_DB_HOST=mysql
      - WORDPRESS_DB_PASSWORD=wp_password
      - WORDPRESS_DB_USER=wp_user
    restart: always

  nginx:
    image: ericmathison/wordpress-nginx:latest
    container_name: nginx
    ports:
      - '80:80'
    volumes:
      - wp_data:/var/www/html
      - wp_cache:/var/cache/nginxfastcgi
    depends_on: 
      - wordpress
    restart: always

volumes:
  db_data:
    driver: local
  wp_data:
    driver: local
  wp_cache:
    driver: local
```
