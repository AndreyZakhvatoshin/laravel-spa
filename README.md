# 🚀 Laravel + Vue 3 SPA (Dockerized)

Полноценный **SPA-проект** на **Laravel** (backend, API) и **Vue 3** (frontend, Vite), упакованный в Docker с готовым `docker-compose`.

---

## 📂 Структура проекта

```plaintext
.
├── backend/                   # Laravel-приложение
│   ├── .env.example
│   └── ...
├── frontend/                  # Vue-приложение
│   ├── .env.example
│   └── ...
├── nginx/                     # Конфиги Nginx
│   └── nginx.conf
├── docker-compose.yml
├── docker-compose.override.yml
├── Makefile
└── init.sh
