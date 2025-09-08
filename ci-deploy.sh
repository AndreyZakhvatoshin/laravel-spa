#!/bin/bash
set -e

echo "🚀 CI/CD Deployment Script — Production Mode"
echo "============================================"

# 1. Проверка переменных окружения
echo "🔍 Проверка обязательных переменных окружения..."
: "${DB_DATABASE?DB_DATABASE не задана}"
: "${DB_USERNAME?DB_USERNAME не задана}"
: "${DB_PASSWORD?DB_PASSWORD не задана}"
: "${RABBITMQ_USER?RABBITMQ_USER не задана}"
: "${RABBITMQ_PASSWORD?RABBITMQ_PASSWORD не задана}"

# 2. Сборка фронтенда
echo "📦 Сборка Vue.js приложения..."
cd frontend && npm ci && npm run build && cd ..

# 3. Сборка бэкенда (Docker образы)
echo "🏗️ Сборка Docker образов..."
docker-compose -f docker-compose.yml build --pull

# 4. Запуск инфраструктуры (без приложения)
echo "🐳 Запуск инфраструктуры (mysql, redis, rabbitmq)..."
docker-compose -f docker-compose.yml up -d mysql redis rabbitmq

# 5. Ожидание готовности БД
echo "⏳ Ожидание готовности MySQL..."
until docker-compose -f docker-compose.yml exec -T mysql mysqladmin ping -h localhost --silent; do
  sleep 5
done

# 6. Запуск миграций
echo "📈 Применение миграций..."
docker-compose -f docker-compose.yml run --rm --no-deps laravel php artisan migrate --force

# 7. Очистка кэша
echo "🧹 Очистка кэша Laravel..."
docker-compose -f docker-compose.yml run --rm --no-deps laravel php artisan optimize:clear

# 8. Запуск всех сервисов
echo "🚀 Запуск всех сервисов..."
docker-compose -f docker-compose.yml up -d --remove-orphans

# 9. Проверка здоровья основных сервисов
echo "✅ Проверка здоровья сервисов..."
docker-compose -f docker-compose.yml ps

echo "🎉 Деплой завершён успешно!"
echo "🌍 Приложение доступно на http://localhost"