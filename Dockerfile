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
    samba-dev \
    libsmbclient \
    gmp \
    gmp-dev \
    imagemagick \
    imagemagick-libs \
    imagemagick-dev \
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
docker-php-ext-configure gd \
  --with-gd \
  --with-freetype-dir=/usr/include/ \
  --with-png-dir=/usr/include/ \
  --with-jpeg-dir=/usr/include/ && \
docker-php-ext-configure intl; \
docker-php-ext-configure mysqli --with-mysqli=mysqlnd; \
docker-php-ext-configure pdo_mysql --with-pdo-mysql=mysqlnd; \
docker-php-ext-configure zip; \
docker-php-ext-install -j "$(nproc)" \
	gd \
	gmp \
	intl \
	bcmath \
	mysqli \
	opcache \
	pdo_mysql \
	zip

RUN pecl install smbclient 
RUN docker-php-ext-enable smbclient
 
 #install imagick
RUN pecl install imagick
RUN docker-php-ext-enable imagick



# install xdebug
# RUN pecl install xdebug
# RUN docker-php-ext-enable xdebug

# RUN echo "xdebug.remote_enable=1" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
# RUN echo "xdebug.remote_autostart=0" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
# RUN echo "xdebug.default_enable=0" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
# RUN echo "xdebug.remote_host=host.docker.internal" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
# RUN echo "xdebug.remote_port=9000" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
# RUN echo "xdebug.remote_connect_back=0" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
# RUN echo "xdebug.profiler_enable=0" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
# RUN echo "xdebug.remote_log=\"/tmp/xdebug.log\"" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini

# install composer
# RUN cd /tmp \
#     && curl -sS https://getcomposer.org/installer | php \
#     && mv composer.phar /usr/local/bin/composer
