<template>
  <div class="login-container">
    <div class="login-box">
      <h2 class="title">Регистрация</h2>
      <form @submit.prevent="handleRegister" class="form">
        <div class="form-group">
          <label for="name" class="label">Имя</label>
          <input v-model="form.name" type="text" id="name" class="input" required>
        </div>
        <div class="form-group">
          <label for="email" class="label">Почта</label>
          <input v-model="form.email" type="email" id="email" class="input" required>
        </div>
        <div class="form-group">
          <label for="password" class="label">Пароль</label>
          <input v-model="form.password" type="password" id="password" class="input" required>
        </div>
        <div class="form-group">
          <label for="password_confirmation" class="label">Повторите пароль</label>
          <input v-model="form.password_confirmation" type="password" id="password_confirmation" class="input" required>
        </div>
        <button type="submit" class="button">Регистрация</button>
        <p v-if="error" class="error">{{ error }}</p>
      </form>
      <p class="link">
        Уже есть аккаунт? <router-link to="/login">Вход</router-link>
      </p>
    </div>
  </div>
</template>

<script setup>
import {ref} from 'vue';
import {useAuthStore} from '../store/auth';
import {useRouter} from 'vue-router';

const form = ref({
  name: '',
  email: '',
  password: '',
  password_confirmation: '',
});
const error = ref(null);
const authStore = useAuthStore();
const router = useRouter();

const handleRegister = async () => {
  console.log('Register attempt:', form.value); // Отладка
  try {
    await authStore.register({
      name: form.value.name,
      email: form.value.email,
      password: form.value.password,
      password_confirmation: form.value.password_confirmation,
    });
    console.log('Registration successful'); // Отладка
    router.push('/');
  } catch (err) {
    console.error('Registration error:', err); // Отладка
    error.value = err.response?.data?.message || 'Registration failed';
  }
};
</script>

<style scoped>
.login-container {
  min-height: 80vh; /* Занимает всю высоту экрана */
  display: flex;
  justify-content: center;
  align-items: center;
  padding: 20px;
  background-color: #f0f2f5;
}

.login-box {
  background-color: #fff;
  padding: 30px;
  border-radius: 12px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
  width: 100%;
  max-width: 450px;
  transition: all 0.3s ease;
}

.login-box:hover {
  box-shadow: 0 6px 25px rgba(0, 0, 0, 0.12);
}

.title {
  font-size: 28px;
  font-weight: 700;
  text-align: center;
  margin-bottom: 25px;
  color: #2c3e50;
  letter-spacing: 0.5px;
}

.form-group {
  margin-bottom: 20px;
}

.label {
  display: block;
  font-size: 14px;
  color: #555;
  margin-bottom: 8px;
  font-weight: 500;
}

.input {
  width: 100%;
  padding: 12px 15px;
  border: 1px solid #e2e8f0;
  border-radius: 8px;
  font-size: 16px;
  transition: all 0.2s;
  background-color: #f8fafc;
}

.input:focus {
  outline: none;
  border-color: #4299e1;
  box-shadow: 0 0 0 3px rgba(66, 153, 225, 0.2);
  background-color: #fff;
}

.button {
  width: 100%;
  padding: 12px;
  background: linear-gradient(to right, #4299e1, #3182ce);
  color: white;
  border: none;
  border-radius: 8px;
  font-size: 16px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s;
  box-shadow: 0 2px 5px rgba(66, 153, 225, 0.2);
}

.button:hover {
  transform: translateY(-1px);
  box-shadow: 0 4px 8px rgba(66, 153, 225, 0.3);
  background: linear-gradient(to right, #3b82f6, #2563eb);
}

.button:active {
  transform: translateY(0);
}

.error {
  color: #e53e3e;
  font-size: 14px;
  text-align: center;
  margin-top: 10px;
  min-height: 20px;
}

.link {
  text-align: center;
  font-size: 14px;
  color: #64748b;
  margin-top: 20px;
  line-height: 1.5;
}

.link a {
  color: #4299e1;
  font-weight: 600;
  text-decoration: none;
  transition: color 0.2s;
}

.link a:hover {
  color: #2b6cb0;
  text-decoration: underline;
}
</style>