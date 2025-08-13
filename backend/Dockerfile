FROM php:8.3-fpm

WORKDIR /var/www/html

RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    zip \
    unzip \
    git \
    curl \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd pdo pdo_mysql

RUN curl -sS https://getcomposer.org/installer | php -- \
    --install-dir=/usr/local/bin \
    --filename=composer

ARG UID=1000
ARG GID=1000
RUN groupadd -g ${GID} appuser \
    && useradd -u ${UID} -g appuser -m -s /bin/bash appuser

COPY . /var/www/html
RUN chown -R appuser:appuser /var/www/html

USER appuser

RUN composer install --no-interaction --optimize-autoloader

RUN chmod -R 775 storage bootstrap/cache

CMD ["php-fpm"]
