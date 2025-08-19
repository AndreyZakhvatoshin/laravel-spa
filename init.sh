#!/bin/bash
set -e

# Обработка флагов
MODE="dev"
for arg in "$@"; do
  case $arg in
    --prod) MODE="prod"; shift ;;
  esac
done

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🚀 Запуск Laravel + Vue SPA — режим: $MODE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Проверка Docker
if ! command -v docker &> /dev/null || ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker или docker-compose не установлен. Установите и попробуйте снова."
    exit 1
fi

# === 1. Создание .env ===
echo "⏳ Создание .env..."
if [ ! -f backend/.env ]; then
  echo "📄 Копируем backend/.env.example → backend/.env"
  cp backend/.env.example backend/.env
  echo "⚠️ Отредактируйте backend/.env (DB_HOST=mysql, REDIS_HOST=redis, RABBITMQ_HOST=rabbitmq и т.д.)!"
  # Добавляем настройки для Redis и RabbitMQ
  echo "REDIS_HOST=redis" >> backend/.env
  echo "REDIS_PORT=6379" >> backend/.env
  echo "REDIS_PASSWORD=null" >> backend/.env
  echo "CACHE_DRIVER=redis" >> backend/.env
  echo "SESSION_DRIVER=redis" >> backend/.env
  echo "QUEUE_CONNECTION=rabbitmq" >> backend/.env
  echo "RABBITMQ_HOST=rabbitmq" >> backend/.env
  echo "RABBITMQ_PORT=5672" >> backend/.env
  echo "RABBITMQ_USER=guest" >> backend/.env
  echo "RABBITMQ_PASSWORD=guest" >> backend/.env
  echo "RABBITMQ_VHOST=/" >> backend/.env
  echo "RABBITMQ_QUEUE=laravel_queue" >> backend/.env
else
  echo "✅ backend/.env уже существует"
fi

if [ ! -f frontend/.env ]; then
  echo "📄 Копируем frontend/.env.example → frontend/.env"
  cp frontend/.env.example frontend/.env
  echo "⚠️ Отредактируйте frontend/.env (VITE_API_BASE_URL=http://nginx/api и т.д.)!"
else
  echo "✅ frontend/.env уже существует"
fi
echo "✅ .env файлы готовы"

# === 2. Запуск docker-compose ===
echo "⏳ Запуск контейнеров..."
if [ "$MODE" = "prod" ]; then
  # Для prod: build Vue сначала, без override
  cd frontend && npm run build && cd ..
  docker-compose -f docker-compose.yml up -d --build --remove-orphans
else
  # Dev: с override
  docker-compose up -d --build --remove-orphans
fi

# Ожидание MySQL (до 60 сек)
echo "⏳ Ожидание запуска MySQL..."
for i in {1..12}; do
  if docker-compose exec -T mysql mysqladmin ping -h localhost --silent; then
    echo "✅ MySQL готов"
    break
  fi
  sleep 5
done
if [ $i -eq 12 ]; then
  echo "❌ MySQL не стартовал вовремя. Проверьте логи: docker-compose logs mysql"
  docker-compose down
  exit 1
fi

# Ожидание Redis (до 60 сек)
echo "⏳ Ожидание запуска Redis..."
for i in {1..12}; do
  if docker-compose exec -T redis redis-cli ping | grep -q PONG; then
    echo "✅ Redis готов"
    break
  fi
  sleep 5
done
if [ $i -eq 12 ]; then
  echo "❌ Redis не стартовал вовремя. Проверьте логи: docker-compose logs redis"
  docker-compose down
  exit 1
fi

# Ожидание RabbitMQ (до 60 сек)
echo "⏳ Ожидание запуска RabbitMQ..."
for i in {1..12}; do
  if docker-compose exec -T rabbitmq rabbitmqctl status > /dev/null 2>&1; then
    echo "✅ RabbitMQ готов"
    break
  fi
  sleep 5
done
if [ $i -eq 12 ]; then
  echo "❌ RabbitMQ не стартовал вовремя. Проверьте логи: docker-compose logs rabbitmq"
  docker-compose down
  exit 1
fi

# === 3. Установка зависимостей Laravel ===
echo "⏳ Установка зависимостей Laravel..."
# Очистка vendor перед установкой
docker-compose exec -T laravel rm -rf /var/www/html/vendor
docker-compose exec -T laravel composer require predis/predis vladimir-yuldashev/laravel-queue-rabbitmq:^14.2.0 --no-interaction --with-all-dependencies
docker-compose exec -T laravel composer install --no-interaction --optimize-autoloader
echo "✅ Зависимости Laravel установлены"

# === 4. Проверка и установка прав ===
echo "⏳ Установка прав на vendor, storage и cache..."
docker-compose exec -T laravel chown -R appuser:appuser /var/www/html
docker-compose exec -T laravel chmod -R 775 /var/www/html/vendor /var/www/html/storage /var/www/html/bootstrap/cache
echo "✅ Права установлены"

# === 5. Генерация APP_KEY ===
echo "⏳ Генерация APP_KEY..."
docker-compose exec -T laravel php artisan key:generate --force
echo "✅ APP_KEY сгенерирован"

# === 6. Установка зависимостей Vue ===
echo "⏳ Установка зависимостей Vue..."
docker-compose exec -T vue npm install
echo "✅ Зависимости Vue установлены"

# === 7. Миграции ===
echo "⏳ Сброс и выполнение миграций..."
docker-compose exec -T laravel php artisan migrate:fresh --seed --force
echo "✅ Миграции и сиды выполнены"

# === 8. Очистка кэшей Laravel ===
echo "⏳ Очистка кэшей Laravel..."
docker-compose exec -T laravel php artisan optimize:clear
echo "✅ Кэш Laravel очищен"

# === 9. Запуск очереди RabbitMQ (только в dev) ===
if [ "$MODE" = "dev" ]; then
  echo "⏳ Запуск очереди RabbitMQ..."
  docker-compose exec -T laravel php artisan queue:work --queue=laravel_queue --tries=3 &
  echo "✅ Очередь RabbitMQ запущена в фоне"
fi

# === 10. Завершение ===
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Проект успешно запущен!"
if [ "$MODE" = "prod" ]; then
  echo "Prod: http://localhost (Nginx на порту 80)"
else
  echo "Dev: http://localhost (Nginx на 80, прокси на Vite)"
  echo "Vite direct: http://localhost:5173"
fi
echo "phpMyAdmin: http://localhost:8080 (user: root, pass: root)"
echo "Redis CLI: docker-compose exec redis redis-cli"
echo "RabbitMQ Management UI: http://localhost:15672 (user: guest, pass: guest)"
echo "Логи: docker-compose logs -f"
echo "Для остановки: make down"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Trap для cleanup при ошибке
trap 'echo "❌ Ошибка! Остановка контейнеров..."; docker-compose down' ERR