<template>
  <div class="home">
    <main class="home-main">
      <div class="auth-card">
        <h2>Добро пожаловать 👋</h2>
        <div class="auth-buttons">
          <router-link to="/login" class="btn btn-primary">Войти</router-link>
          <router-link to="/register" class="btn btn-secondary">Регистрация</router-link>
        </div>
      </div>
    </main>
  </div>
</template>

<script setup>
import { useAuthStore } from '@/store/auth'
import { useRouter } from 'vue-router'

const authStore = useAuthStore()
const router = useRouter()

const handleLogout = () => {
  authStore.logout()
  router.push('/')
}
</script>

<style scoped>
.home {
  display: flex;
  flex-direction: column; /* если нужна колонка; при необходимости можно менять */
  justify-content: center; /* вертикальное центрирование */
  align-items: center; /* горизонтальное центрирование */
  font-family: "Segoe UI", Tahoma, Geneva, Verdana, sans-serif;
  color: #333;

  /* Для полного центрирования по высоте родителю нужна фиксированная высота: */
  height: 70vh; /* или нужная вам высота */
}

.auth-card {
  background: #fff;
  padding: 30px;
  border-radius: 12px;
  box-shadow: 0 4px 16px rgba(0,0,0,0.1);
  text-align: center;
  width: 100%;
  max-width: 400px;
}

.auth-card h2 {
  font-size: 1.5rem;
  margin-bottom: 20px;
  color: #222;
}

.auth-buttons {
  display: flex;
  flex-direction: column;
  gap: 15px;
}

.btn {
  display: inline-block;
}
</style>