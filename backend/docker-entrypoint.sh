#!/usr/bin/env bash
set -e

# Переходим в рабочую директорию
cd /var/www/html || exit 1

# Устанавливаем переменные окружения по умолчанию, если не заданы
: "${APP_ENV:=production}"
: "${APP_DEBUG:=false}"

# Устанавливаем владельца (если смонтирован том, это безопасно)
chown -R appuser:appuser /var/www/html || true
chmod -R 775 storage bootstrap/cache || true

# Если нет vendor - устанавливаем зависимости. Выполняем composer от имени appuser
if [ ! -d "vendor" ] || [ ! -f "vendor/autoload.php" ]; then
  echo "[entrypoint] vendor not found — запускаем composer install (APP_ENV=$APP_ENV)"

  if [ "$APP_ENV" = "production" ]; then
    # В проде: не ставим dev-пакеты и пропускаем composer-скрипты (чтобы не падать из-за dev-only провайдеров)
    su -s /bin/sh appuser -c "composer install --no-dev --no-interaction --optimize-autoloader --no-scripts"
  else
    # В dev: ставим все (включая require-dev)
    su -s /bin/sh appuser -c "composer install --no-interaction --optimize-autoloader"
  fi
else
  echo "[entrypoint] vendor already exists, пропускаем composer install"
fi

# Теперь выполняем artisan команды — безопасно, т.к. .env монтируется/существует во время запуска контейнера
if [ "$APP_ENV" = "production" ]; then
  echo "[entrypoint] production tasks: clearing and caching config/routes/views"
  php artisan config:clear || true
  php artisan route:clear || true
  php artisan view:clear || true
  php artisan config:cache || true
  php artisan route:cache || true
  php artisan view:cache || true
else
  echo "[entrypoint] dev tasks: clearing caches"
  php artisan config:clear || true
  php artisan route:clear || true
  php artisan view:clear || true
fi

# Убедимся в правах на папки
chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache || true
chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache || true

# Запустить переданную команду (обычно php-fpm)
exec "$@"
