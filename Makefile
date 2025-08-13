# Makefile для Laravel + Vue SPA в Docker
# Использование: make <цель>, например make up
# Опционально: make up MODE=prod для прод-режима

# Переменные
COMPOSE_CMD = docker-compose
LARAVEL_EXEC = $(COMPOSE_CMD) exec laravel
VUE_EXEC = $(COMPOSE_CMD) exec vue
MODE ?= dev  # По умолчанию dev

ifeq ($(MODE),prod)
	COMPOSE_FILES = -f docker-compose.yml
else
	COMPOSE_FILES = -f docker-compose.yml -f docker-compose.override.yml
endif

# Основные цели

.PHONY: help
help: ## Показать эту справку
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

up: ## Запустить контейнеры (build + up)
	$(COMPOSE_CMD) $(COMPOSE_FILES) up -d --build --remove-orphans

down: ## Остановить и удалить контейнеры
	$(COMPOSE_CMD) $(COMPOSE_FILES) down --remove-orphans

build: ## Собрать образы
	$(COMPOSE_CMD) $(COMPOSE_FILES) build

init: ## Инициализация проекта (запустить init.sh)
	./init.sh $(if $(filter prod,$(MODE)),--prod,)

# Миграции и БД
migrate: ## Выполнить миграции
	$(LARAVEL_EXEC) php artisan migrate --force

rollback: ## Откатить последнюю миграцию
	$(LARAVEL_EXEC) php artisan migrate:rollback --force

fresh: ## Полный сброс БД + миграции + сиды
	$(LARAVEL_EXEC) php artisan migrate:fresh --seed --force

seed: ## Выполнить сиды
	$(LARAVEL_EXEC) php artisan db:seed --force

# Зависимости
composer-install: ## Установить Composer зависимости (Laravel)
	$(LARAVEL_EXEC) composer install --no-interaction --optimize-autoloader

npm-install: ## Установить NPM зависимости (Vue)
	$(VUE_EXEC) npm install

npm-build: ## Собрать Vue (для prod)
	$(VUE_EXEC) npm run build

# Кэш и права
cache-clear: ## Очистить кэш Laravel
	$(LARAVEL_EXEC) php artisan optimize:clear

storage-permissions: ## Установить права на storage
	$(LARAVEL_EXEC) chmod -R 775 storage bootstrap/cache
	$(LARAVEL_EXEC) chown -R www-data:www-data storage bootstrap/cache

# Дебаггинг
logs: ## Показать логи (follow)
	$(COMPOSE_CMD) $(COMPOSE_FILES) logs -f

exec-laravel: ## Зайти в bash Laravel контейнера
	$(LARAVEL_EXEC) bash

exec-vue: ## Зайти в bash Vue контейнера
	$(VUE_EXEC) bash

exec-mysql: ## Зайти в MySQL CLI
	$(COMPOSE_CMD) exec mysql mysql -u root -proot

# Тестирование
test: ## Запустить тесты Laravel
	$(LARAVEL_EXEC) php artisan test