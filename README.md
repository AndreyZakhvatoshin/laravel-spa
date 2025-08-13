# 🚀 Laravel + Vue 3 SPA (Dockerized)

Полноценный **SPA-проект** на **Laravel** (backend, API) и **Vue 3** (frontend, Vite), упакованный в Docker с готовым `docker-compose`.

---

## 📂 Состав проекта

laravel-vue-spa/
│
├── backend/ # Laravel backend (PHP 8.3, Composer)
├── frontend/ # Vue 3 + Vite frontend (Node.js)
├── nginx/ # Конфиг Nginx
├── .env.example # Переменные окружения
├── .gitignore
├── docker-compose.override.yml # Конфигурация для develop
├── docker-compose.yml # Конфигурация сервисов
├── init.sh # Скрипт инициализации и запуска проекта
├── Makefile # Make команды
└── README.md # Этот файл