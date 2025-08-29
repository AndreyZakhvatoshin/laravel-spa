<template>
  <div class="profile-container">
    <div class="profile-box">
      <h2 class="title">Profile</h2>
      <div v-if="loading" class="loading">Loading...</div>
      <div v-else-if="user" class="user-info">
        <p><strong>Name:</strong> {{ user.name }}</p>
        <p><strong>Email:</strong> {{ user.email }}</p>
        <p><strong>Roles:</strong> {{ user.roles ? user.roles.map(r => r.name).join(', ') : 'No roles' }}</p>
        <button @click="handleLogout" class="button">Logout</button>
      </div>
      <p v-else class="error">Failed to load profile. Please log in again.</p>
    </div>
  </div>
</template>

<script setup>
import {ref, onMounted} from 'vue';
import {useAuthStore} from '../store/auth';
import {useRouter} from 'vue-router';

const user = ref(null);
const loading = ref(true);
const authStore = useAuthStore();
const router = useRouter();

onMounted(async () => {
  try {
    loading.value = true;
    await authStore.fetchUser();
    user.value = authStore.user;
  } catch (err) {
    console.error('Failed to fetch user:', err);
    router.push('/login');
  } finally {
    loading.value = false;
  }
});

const handleLogout = async () => {
  await authStore.logout();
  router.push('/login');
};
</script>

<style scoped>
.profile-container {
  min-height: 100vh;
  background-color: #f5f5f5;
  display: flex;
  justify-content: center;
  align-items: center;
}

.profile-box {
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

.user-info {
  text-align: center;
}

.user-info p {
  margin-bottom: 10px;
  color: #555;
}

.button {
  width: 100%;
  padding: 10px;
  background-color: #dc3545;
  color: white;
  border: none;
  border-radius: 4px;
  font-size: 16px;
  cursor: pointer;
  margin-top: 20px;
}

.button:hover {
  background-color: #c82333;
}

.loading {
  color: #666;
  text-align: center;
}

.error {
  color: #dc3545;
  text-align: center;
  font-size: 14px;
}
</style>