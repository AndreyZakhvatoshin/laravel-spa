# 🚀 Laravel + Vue SPA — Fullstack Docker-проект с мониторингом

> **Современный fullstack-проект на Laravel 10+ и Vue 3 с Vite, Reverb (WebSockets), Horizon, RabbitMQ, Redis, MySQL и полноценным DevOps-стеком.**

---

## 🌟 Основные возможности

- ✅ **SPA на Vue 3** с Vite (HMR в dev, оптимизированная сборка в prod)
- ✅ **Backend на Laravel** с API, очередями, Horizon, Reverb (WebSockets)
- ✅ **Гибкая Docker-инфраструктура** — один скрипт для dev и prod
- ✅ **Автоматические миграции, сиды, зависимости**
- ✅ **Мониторинг: Prometheus + Grafana + cAdvisor** — метрики приложения, контейнеров, БД
- ✅ **Готово к деплою** — CI/CD-скрипт, healthcheck, логирование
- ✅ **Разделение dev/prod** — через `docker-compose.override.yml`
- ✅ **Horizon, phpMyAdmin, RabbitMQ UI** — встроенные инструменты администрирования

---

## 🧩 Технологический стек

| Категория          | Технологии                                                          |
|--------------------|---------------------------------------------------------------------|
| **Frontend**       | Vue 3, Vite, TypeScript, Pinia, Vue Router                          |
| **Backend**        | Laravel 12+, PHP 8.3, Reverb, Horizon, Redis, RabbitMQ, MySQL       |
| **Инфраструктура** | Docker, Docker Compose, Nginx                                       |
| **DevOps**         | Healthcheck, Мониторинг, CI/CD-скрипт, .env-менеджмент, логирование |
| **Очереди**        | RabbitMQ (основные задачи), Redis (Horizon, кэш, сессии)            |

---

## 🚀 Быстрый старт

### 1. Клонируйте репозиторий

```bash
git clone https://github.com/AndreyZakhvatoshin/laravel-spa
cd laravel-spa