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
  echo "⚠️ Отредактируйте backend/.env (DB_HOST=mysql, APP_KEY и т.д.)!"
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

# Ожидание MySQL (простой цикл, до 60 сек)
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

# === 3. Установка зависимостей Laravel ===
echo "⏳ Установка зависимостей Laravel..."
docker-compose exec laravel composer install --no-interaction --optimize-autoloader
echo "✅ Зависимости Laravel установлены"

# === 4. Генерация APP_KEY ===
echo "⏳ Генерация APP_KEY..."
docker-compose exec laravel php artisan key:generate --force
echo "✅ APP_KEY сгенерирован"

# === 5. Установка зависимостей Vue ===
echo "⏳ Установка зависимостей Vue..."
docker-compose exec vue npm install
echo "✅ Зависимости Vue установлены"

# === 7. Миграции ===
echo "⏳ Сброс и выполнение миграций..."
docker-compose exec laravel php artisan migrate:fresh --seed --force
echo "✅ Миграции и сиды выполнены"

# === 8. Очистка кэшей Laravel ===
echo "⏳ Очистка кэшей Laravel..."
docker-compose exec laravel php artisan optimize:clear
echo "✅ Кэш Laravel очищен"

# === 9. Завершение ===
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Проект успешно запущен!"
if [ "$MODE" = "prod" ]; then
  echo "Prod: http://localhost (Nginx на порту 80)"
else
  echo "Dev: http://localhost (Nginx на 80, прокси на Vite)"
  echo "Vite direct: http://localhost:5173"
fi
echo "phpMyAdmin: http://localhost:8080 (user: root, pass: root)"
echo "Логи: docker-compose logs -f"
echo "Для остановки: docker-compose down"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Trap для cleanup при ошибке
trap 'echo "❌ Ошибка! Остановка контейнеров..."; docker-compose down' ERR