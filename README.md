# Wordpress PHP-FPM Docker Image with Redis Support

![GitHub Workflow Status](https://img.shields.io/github/workflow/status/eric-mathison/docker-wordpress-php/Build%20Docker%20Image%20and%20Push?style=for-the-badge)

This is a Wordpress PHP-FPM Docker Image designed to work with this [NGINX Docker Image](https://github.com/eric-mathison/docker-wordpress-nginx). This image also includes support for Redis caching.

## How to Use this Image

### Start a `wordpress` server instance

```bash
docker run -p 9000:9000 --name wordpress \
-e WORDPRESS_DB_HOST=localhost \
-e WORDPRESS_DB_USER=db-user \
-e WORDPRESS_DB_PASSWORD=db-password \
-e MAX_CHILDREN=3 \
-e START_SERVERS=1 \
-e MIN_SPARES=1 \
-e MAX_SPARES=2 \
-d ericmathison/wordpress:tag
```

### Using Docker Compose

Example docker-compose.yml file:

```yaml
version: "3.3"

services:
    nginx:
        image: ericmathison/wordpress:latest
        restart: always
        volumes:
            - wp-data:/var/www/html
        environment:
            WORDPRESS_DB_HOST: localhost
            WORDPRESS_DB_USER: db-user
            WORDPRESS_DB_PASSWORD: db-password
            MAX_CHILDREN: 3
            START_SERVERS: 1
            MIN_SPARES: 1
            MAX_SPARES: 2
```

If you want to enable Redis caching, you can specify the hostname by adding this optional environment variable: `REDIS_HOST: redis-host`.

### Environment Variables

This image depends on the use of several environment variables:

`WORDPRESS_DB_HOST` Set this value to your database host
`WORDPRESS_DB_USER` Set this to the database username
`WORDPRESS_DB_PASSWORD` Set this value for the database password
`MAX_CHILDREN` Specify how many php processes you want max
`START_SERVERS` Specify the amount of php process to start with
`MIN_SPARES` Specify the number of minimum spare processes
`MAX_SPARES` Specify the number of maximum spare processes
`REDIS_HOST` Set this value to your Redis hostname

## Configuration

### PHP.ini Settings

Several PHP.ini settings are set by default. If you wish to change these, you may change the values located in `/wordpress.ini`.

```
memory_limit = 512M
upload_max_filesize = 200M
post_max_size = 200M
max_execution_time = 600
max_input_time = 600
```

### GH Actions

This repo is configured to automatically build this Docker image and upload it to your Docker Hub account.

1. To setup this action, you need to set the following enviroment secrets:

-   `DOCKERHUB_USERNAME` - this is your Docker Hub username
-   `DOCKERHUB_TOKEN` - this is your Docker Hub API key

2. You need to update the tags for the build in `/.github/workflows/deploy.yml` on line 26.
