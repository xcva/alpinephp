FROM php:8.0-fpm-alpine3.14

RUN apk --update add ca-certificates \
    && apk add -U \
    postgresql \
    freetype-dev \
    icu-dev \
    libjpeg-turbo-dev \
    libpng-dev \
    libmcrypt-dev \
    libpng-dev \
    curl \
    unzip \
    libzip-dev \
    zip \
    nano && \
    rm -rf /var/lib/apt/lists/*


    RUN set -eux; \
	docker-php-ext-configure intl; \
	docker-php-ext-configure mysqli --with-mysqli=mysqlnd; \
	docker-php-ext-configure pdo_mysql --with-pdo-mysql=mysqlnd; \
	docker-php-ext-configure zip; \
    docker-php-ext-configure pdo_pgsql; \
	docker-php-ext-install -j "$(nproc)" \
		gd \
		intl \
		mysqli \
		opcache \
		pdo_mysql \
		zip
