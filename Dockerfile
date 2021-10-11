FROM php:8-fpm-alpine

######
# You can configure php extensions using docker-php-ext-configure
# You can install php extensions using docker-php-ext-install
######

# define timezone
# RUN echo "America/Sao_Paulo" > /etc/timezone
# RUN dpkg-reconfigure -f noninteractive tzdata
# RUN /bin/echo -e "LANG=\"en_US.UTF-8\"" > /etc/default/local

# install dependencies

RUN apk add --no-cache \
    && apk add -U \
    $PHPIZE_DEPS \
    && pecl install pthreads \
    && docker-php-ext-enable pthreads \
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


# configure, install and enable all php packages, format updated with Tianon's comment below
RUN set -eux; \
	docker-php-ext-configure gd --enable-gd --with-freetype; \
	docker-php-ext-configure intl; \
	docker-php-ext-configure mysqli --with-mysqli=mysqlnd; \
	docker-php-ext-configure pdo_mysql --with-pdo-mysql=mysqlnd; \
	docker-php-ext-configure zip; \
	docker-php-ext-install -j "$(nproc)" \
		gd \
		intl \
		mysqli \
		opcache \
		pdo_mysql \
		zip

# install xdebug
RUN pecl install xdebug
RUN docker-php-ext-enable xdebug

RUN echo "xdebug.remote_enable=1" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
RUN echo "xdebug.remote_autostart=0" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
RUN echo "xdebug.default_enable=0" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
RUN echo "xdebug.remote_host=host.docker.internal" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
RUN echo "xdebug.remote_port=9000" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
RUN echo "xdebug.remote_connect_back=0" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
RUN echo "xdebug.profiler_enable=0" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
RUN echo "xdebug.remote_log=\"/tmp/xdebug.log\"" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini

#install imagick
RUN pecl install imagick
RUN docker-php-ext-enable imagick

# install composer
RUN cd /tmp \
    && curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/composer
