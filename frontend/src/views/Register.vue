<template>
  <div class="max-w-md mx-auto mt-10 p-6 bg-white rounded-lg shadow">
    <h1 class="text-2xl font-bold mb-4">Регистрация</h1>

    <form @submit.prevent="register">
      <div class="mb-4">
        <label class="block mb-1">Имя</label>
        <input v-model="form.name" type="text" class="w-full border rounded p-2" required />
      </div>

      <div class="mb-4">
        <label class="block mb-1">Email</label>
        <input v-model="form.email" type="email" class="w-full border rounded p-2" required />
      </div>

      <div class="mb-4">
        <label class="block mb-1">Пароль</label>
        <input v-model="form.password" type="password" class="w-full border rounded p-2" required />
      </div>

      <button type="submit" class="w-full bg-blue-500 text-white p-2 rounded hover:bg-blue-600">
        Зарегистрироваться
      </button>
    </form>

    <p v-if="message" class="mt-4 text-green-600">{{ message }}</p>
    <p v-if="error" class="mt-4 text-red-600">{{ error }}</p>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import axios from 'axios'

const form = ref({
  name: '',
  email: '',
  password: ''
})

const message = ref('')
const error = ref('')
const apiUrl = import.meta.env.VITE_API_URL

const register = async () => {
  message.value = ''
  error.value = ''
  try {
    const res = await axios.post(`${apiUrl}/register`, form.value)
    message.value = res.data.message
  } catch (err) {
    error.value = err.response?.data?.message || 'Ошибка регистрации'
  }
}
</script>
