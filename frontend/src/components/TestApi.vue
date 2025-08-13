<template>
  <div>
    <h2>Тест API</h2>
    <button @click="fetchData">Получить данные</button>
    <router-link to="/">Вернуться на главную</router-link>
    <p v-if="loading">Загрузка...</p>
    <p v-if="error" style="color: red">{{ error }}</p>
    <pre v-if="data">{{ data }}</pre>
  </div>
</template>

<script setup>
import { ref } from 'vue';

const data = ref(null);
const loading = ref(false);
const error = ref(null);

const fetchData = async () => {
  loading.value = true;
  error.value = null;
  try {
    const response = await fetch(`${import.meta.env.VITE_API_BASE_URL}/test`);
    if (!response.ok) throw new Error(`HTTP error: ${response.status}`);
    data.value = await response.json();
  } catch (err) {
    error.value = 'Ошибка при запросе: ' + err.message;
  } finally {
    loading.value = false;
  }
};
</script>

<style scoped>
pre {
  background: #f4f4f4;
  padding: 10px;
  border-radius: 5px;
}
</style>