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
    libpq-dev \
    librabbitmq-dev \
    libicu-dev \
    icu-devtools \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd pdo pdo_mysql sockets intl pcntl \
    && pecl install redis amqp \
    && docker-php-ext-enable redis amqp pcntl \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN curl -sS https://getcomposer.org/installer | php -- \
    --install-dir=/usr/local/bin \
    --filename=composer

ARG COMPOSER_FLAGS="--no-dev --no-plugins --no-scripts"
ARG UID=1000
ARG GID=1000
RUN groupadd -g ${GID} appuser \
    && useradd -u ${UID} -g appuser -m -s /bin/bash appuser

# Копируем composer.json и lock отдельно — для кэширования
COPY composer.json composer.lock ./

RUN composer install ${COMPOSER_FLAGS} --no-autoloader --optimize-autoloader

# Копируем остальной код
COPY . .

# Генерируем автозагрузчик БЕЗ выполнения скриптов
RUN composer dump-autoload --optimize --no-scripts --no-plugins

# Меняем владельца
RUN chown -R appuser:appuser /var/www/html
RUN chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

USER appuser

CMD ["php-fpm"]
