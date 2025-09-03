<template>
  <div class="login-container">
    <div class="login-box">
      <h2 class="title">Вход</h2>
      <form @submit.prevent="handleLogin" class="form">
        <div class="form-group">
          <label for="email" class="label">Почта</label>
          <input v-model="form.email" type="email" id="email" class="input" required>
        </div>
        <div class="form-group">
          <label for="password" class="label">Пароль</label>
          <input v-model="form.password" type="password" id="password" class="input" required>
        </div>
        <button type="submit" class="button">Войти</button>
        <p v-if="error" class="error">{{ error }}</p>
      </form>
      <p class="link">
        Нет аккаунта? <router-link to="/register">Регистрация</router-link>
      </p>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue';
import { useAuthStore } from '../store/auth';
import { useRouter } from 'vue-router';

const form = ref({
  email: '',
  password: '',
});
const error = ref(null);
const authStore = useAuthStore();
const router = useRouter();

const handleLogin = async () => {
  try {
    await authStore.login({
      email: form.value.email,
      password: form.value.password,
    });
    router.push('/profile');
  } catch (err) {
    error.value = err.response?.data?.message || 'Login failed';
  }
};
</script>

<style scoped>
.login-container {
  min-height: 80vh;
  display: flex;
  justify-content: center;
  align-items: center;
}

.login-box {
  background-color: white;
  padding: 20px;
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
  width: 100%;
  max-width: 400px;
}

.title {
  font-size: 24px;
  font-weight: bold;
  text-align: center;
  margin-bottom: 20px;
  color: #333;
}

.form-group {
  margin-bottom: 15px;
}

.label {
  display: block;
  font-size: 14px;
  color: #555;
  margin-bottom: 5px;
}

.input {
  width: 100%;
  padding: 8px;
  border: 1px solid #ddd;
  border-radius: 4px;
  font-size: 14px;
}

.button {
  width: 100%;
  padding: 10px;
  background-color: #007bff;
  color: white;
  border: none;
  border-radius: 4px;
  font-size: 16px;
  cursor: pointer;
}

.button:hover {
  background-color: #0056b3;
}

.error {
  color: #dc3545;
  font-size: 12px;
  text-align: center;
}

.link {
  text-align: center;
  font-size: 12px;
  color: #666;
}

.link a {
  color: #007bff;
  text-decoration: none;
}

.link a:hover {
  text-decoration: underline;
}
</style>