FROM php:8.0.0-fpm-alpine
RUN apk --update add --no-cache \
$PHPIZE_DEPS mysql-client msmtp perl wget \
procps shadow libzip libpng libjpeg-turbo \
libwebp freetype icu samba-dev libsmbclient \
gmp gmp-dev imagemagick imagemagick-dev

RUN pecl install smbclient 
RUN docker-php-ext-enable smbclient

 
RUN apk add --no-cache --virtual build-essentials \
    icu-dev icu-libs zlib-dev g++ make automake autoconf libzip-dev imagemagick-dev \
    libpng-dev libwebp-dev libjpeg-turbo-dev freetype-dev && \
    docker-php-ext-configure gd --enable-gd --with-freetype --with-jpeg --with-webp && \
    docker-php-ext-install gd && \
    docker-php-ext-install gmp && \
    docker-php-ext-install bcmath && \
    docker-php-ext-install mysqli && \
    docker-php-ext-install pdo_mysql && \
    docker-php-ext-install intl && \
    docker-php-ext-install opcache && \
    docker-php-ext-install exif && \
    docker-php-ext-install zip && \
    pecl install imagick && \
    docker-php-ext-enable imagick && \
    apk del build-essentials && \
#     apk del autoconf g++ libtool make pcre-dev && \
    rm -rf /usr/src/php*

RUN wget https://getcomposer.org/composer-stable.phar -O /usr/local/bin/composer && chmod +x /usr/local/bin/composer
