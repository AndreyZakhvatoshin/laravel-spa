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
  echo "RABBITMQ_QUEUE=chat_messages" >> backend/.env
  echo "BROADCAST_DRIVER=reverb" >> backend/.env
  echo "REVERB_APP_ID=chatapp" >> backend/.env
  echo "REVERB_APP_KEY=chatappkey" >> backend/.env
  echo "REVERB_APP_SECRET=chatappsecret" >> backend/.env
  echo "REVERB_HOST=websockets" >> backend/.env
  echo "REVERB_PORT=6001" >> backend/.env
  echo "REVERB_SCHEME=http" >> backend/.env
else
  echo "✅ backend/.env уже существует"
fi

if [ ! -f frontend/.env ]; then
  echo "📄 Копируем frontend/.env.example → frontend/.env"
  cp frontend/.env.example frontend/.env
  echo "⚠️ Отредактируйте frontend/.env (VITE_API_BASE_URL=http://nginx/api и т.д.)!"
  echo "VITE_API_BASE_URL=http://nginx/api" >> frontend/.env
  echo "VITE_REVERB_HOST=localhost" >> frontend/.env
  echo "VITE_REVERB_PORT=6001" >> frontend/.env
  echo "VITE_REVERB_KEY=chatappkey" >> frontend/.env
  echo "VITE_REVERB_SCHEME=http" >> frontend/.env
else
  echo "✅ frontend/.env уже существует"
fi
echo "✅ .env файлы готовы"

# === 3. Запуск docker-compose ===
echo "🐳 Запуск контейнеров..."
if [ "$MODE" = "prod" ]; then
  cd frontend && npm run build && cd ..
  docker-compose -f docker-compose.yml up -d --build --remove-orphans
else
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

# === 4. Установка зависимостей Laravel ===
echo "⏳ Установка зависимостей Laravel..."
docker-compose exec -T laravel composer install --no-interaction --optimize-autoloader
docker-compose exec -T laravel composer dump-autoload
echo "✅ Зависимости Laravel установлены"

# === 5. Публикация конфигурации Reverb ===
echo "⏳ Публикация конфигурации Laravel Reverb..."
if [ ! -f backend/config/reverb.php ]; then
  docker-compose exec -T laravel php artisan reverb:install --no-interaction
  echo "✅ Конфигурация Reverb опубликована"
fi
echo "✅ Конфигурация Reverb уже существует"

# === 6. Проверка и установка прав ===
echo "⏳ Установка прав на vendor, storage, cache и Jobs..."
docker-compose exec -T laravel chown -R appuser:appuser /var/www/html
docker-compose exec -T laravel chmod -R 775 /var/www/html/vendor /var/www/html/storage /var/www/html/bootstrap/cache /var/www/html/app/Jobs
echo "✅ Права установлены"

# === 7. Генерация APP_KEY ===
echo "⏳ Генерация APP_KEY..."
docker-compose exec -T laravel php artisan key:generate --force
echo "✅ APP_KEY сгенерирован"

# === 8. Установка зависимостей Vue ===
echo "⏳ Установка зависимостей Vue..."
docker-compose exec -T vue npm install
echo "✅ Зависимости Vue установлены"

# === 9. Миграции ===
if [ "$MODE" = "dev" ]; then
  echo "⏳ Выполнение свежих миграций с сидами..."
  docker-compose run --rm laravel php artisan migrate:fresh --seed --force
else
  # Для prod: только миграции (без удаления данных!)
  echo "⏳ Применение миграций..."
  docker-compose run --rm migrate
fi

# === 10. Очистка кэшей Laravel ===
echo "⏳ Очистка кэшей Laravel..."
docker-compose exec -T laravel php artisan optimize:clear
echo "✅ Кэш Laravel очищен"

# === 11. Запуск очереди RabbitMQ ===
if [ "$MODE" = "dev" ]; then
  echo "⏳ Запуск очереди RabbitMQ..."
  docker-compose exec -T laravel php artisan queue:work --queue=chat_messages --tries=3 &
  echo "✅ Очередь RabbitMQ запущена в фоне"
fi

# === 12. Завершение ===
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