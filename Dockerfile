FROM php:8.1-fpm

LABEL maintainer="ZoomoVN <zoomovn@gmail.com>"

ENV TERM xterm

RUN apt-get update && apt-get install -y \
    libpq-dev \
    curl \
    libjpeg-dev \
    libpng-dev \
    libfreetype6-dev \
    libssl-dev \
    libmcrypt-dev \
    nginx \
    --no-install-recommends

# Install GD extension separately with additional configuration
RUN docker-php-ext-configure gd \
    --with-freetype=/usr/include/ \
    --with-jpeg=/usr/include/

# Install mongodb, xdebug
RUN pecl install mongodb \
    && pecl install xdebug \
    && docker-php-ext-enable xdebug

# Install extensions using the helper script provided by the base image
RUN apt-get update && apt-get install -y libmcrypt-dev libpq-dev libjpeg-dev libzip-dev \
    && docker-php-ext-install \
    pdo_mysql \
    pdo_pgsql \
    zip

# Install other tools
RUN apt-get install supervisor net-tools vim -y

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN usermod -u 1000 www-data

COPY laravel.ini /usr/local/etc/php/conf.d
COPY laravel.pool.conf /usr/local/etc/php-fpm.d/
COPY nginx.conf /etc/nginx/nginx.conf
COPY default.conf /etc/nginx/conf.d/default.conf
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

RUN usermod -u 1000 www-data
WORKDIR /var/www/laravel

# Default command
CMD ["/usr/bin/supervisord"]

EXPOSE 80 443
