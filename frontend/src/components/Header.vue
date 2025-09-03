<template>
  <header class="header">
    <div class="logo">
      <h1>Kanban Board</h1>
    </div>
    <div class="right">
      <div v-if="authStore.isAuthenticated" class="user-info">
        <img
            :src="authStore.userAvatar"
            alt="Профиль"
            class="user-avatar"
            title="Профиль пользователя"
        />
        <span class="user-name" v-if="authStore.userName">{{ authStore.userName }}</span>
        <button @click="handleLogout" class="btn-logout">Выйти</button>
      </div>
      <div v-else class="auth-buttons">
        <button @click="$router.push('/login')" class="btn-login">Войти</button>
        <button @click="$router.push('/register')" class="btn-register">Регистрация</button>
      </div>
    </div>
  </header>
</template>

<script>
import { useAuthStore } from '@/store/auth'
import { mapActions } from 'pinia'

export default {
  name: 'AppHeader',
  computed: {
    authStore() {
      return useAuthStore()
    }
  },
  methods: {
    ...mapActions(useAuthStore, ['logout']),
    handleLogout() {
      this.logout()
      // Перенаправляем на главную страницу после выхода
      this.$router.push('/')
    }
  }
}
</script>

<style scoped>
.header {
  background: #333;
  color: #fff;
  padding: 1rem 2rem;
  display: flex;
  justify-content: space-between;
  align-items: center;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
  position: sticky;
  top: 0;
  z-index: 100;
}

.logo h1 {
  margin: 0;
  font-size: 1.5rem;
  font-weight: 600;
}

.right {
  display: flex;
  align-items: center;
}

.user-info {
  display: flex;
  align-items: center;
  gap: 0.75rem;
}

.user-avatar {
  width: 32px;
  height: 32px;
  border-radius: 50%;
  object-fit: cover;
}

.user-name {
  font-size: 0.9rem;
}

.auth-buttons {
  display: flex;
  gap: 0.75rem;
}

.btn-login, .btn-register, .btn-logout {
  background: none;
  border: 1px solid #fff;
  color: white;
  cursor: pointer;
  font-size: 0.9rem;
  padding: 0.5rem 1rem;
  border-radius: 4px;
  transition: all 0.3s ease;
}

.btn-login:hover, .btn-register:hover, .btn-logout:hover {
  background: rgba(255, 255, 255, 0.1);
}

@media (max-width: 768px) {
  .header {
    padding: 0.75rem 1rem;
    flex-direction: column;
    gap: 0.75rem;
  }

  .logo h1 {
    font-size: 1.25rem;
  }

  .auth-buttons, .user-info {
    gap: 0.5rem;
  }

  .btn-login, .btn-register, .btn-logout {
    padding: 0.4rem 0.8rem;
    font-size: 0.8rem;
  }

  .user-name {
    display: none;
  }
}
</style>