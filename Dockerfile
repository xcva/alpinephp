FROM php:8.0-fpm-alpine3.14

RUN set -ex; \
    \
    apk add --no-cache --virtual .build-deps \
        $PHPIZE_DEPS \
        samba-dev \
        libsmbclient \
        autoconf \
        freetype-dev \
        icu-dev \
        libevent-dev \
        libjpeg-turbo-dev \
        libmcrypt-dev \
        libpng-dev \
        libmemcached-dev \
        libxml2-dev \
        libzip-dev \
        openldap-dev \
        pcre-dev \
        postgresql-dev \
        imagemagick \
        imagemagick-libs \
        imagemagick-dev \
        libwebp-dev \
        gmp-dev \
    ; \
    \
    docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp; \
    docker-php-ext-configure ldap; \
    docker-php-ext-install -j "$(nproc)" \
        bcmath \
        exif \
        gd \
        intl \
        ldap \
        opcache \
        pcntl \
        pdo_mysql \
        pdo_pgsql \
        zip \
        gmp \
    ; \
    \
# pecl will claim success even if one install fails, so we need to perform each install separately
    pecl install APCu-5.1.20; \
    pecl install memcached-3.1.5; \
    pecl install redis-5.3.4; \
    pecl install imagick; \
    pecl install smbclient; \
    \
    docker-php-ext-enable \
        apcu \
        memcached \
        redis \
        imagick \
        smbclient \
    ; \
    rm -r /tmp/pear; \
    \
    runDeps="$( \
        scanelf --needed --nobanner --format '%n#p' --recursive /usr/local/lib/php/extensions \
            | tr ',' '\n' \
            | sort -u \
            | awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
    )"; \
    apk add --virtual .nextcloud-phpext-rundeps $runDeps; \
    apk del .build-deps

# set recommended PHP.ini settings
# see https://docs.nextcloud.com/server/stable/admin_manual/configuration_server/server_tuning.html#enable-php-opcache
# ENV PHP_MEMORY_LIMIT 512M
# ENV PHP_UPLOAD_LIMIT 512M
RUN apk add --no-cache imagemagick
RUN { \
        echo 'opcache.enable=1'; \
        echo 'opcache.interned_strings_buffer=8'; \
        echo 'opcache.max_accelerated_files=10000'; \
        echo 'opcache.memory_consumption=128'; \
        echo 'opcache.save_comments=1'; \
        echo 'opcache.revalidate_freq=1'; \
    } > /usr/local/etc/php/conf.d/opcache-recommended.ini; \
    \
    echo 'apc.enable_cli=1' >> /usr/local/etc/php/conf.d/docker-php-ext-apcu.ini; \
    \
    { \
        echo 'memory_limit=${PHP_MEMORY_LIMIT}'; \
        echo 'upload_max_filesize=${PHP_UPLOAD_LIMIT}'; \
        echo 'post_max_size=${PHP_UPLOAD_LIMIT}'; \
    } > /usr/local/etc/php/conf.d/nextcloud.ini; \
