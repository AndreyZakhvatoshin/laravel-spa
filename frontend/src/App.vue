<template>
  <router-view />
</template>

<script setup>
import { onMounted } from 'vue';
import { useAuthStore } from './store/auth';
import { useRouter } from 'vue-router';

onMounted(() => {
  const authStore = useAuthStore();
  if (authStore.token) {
    authStore.fetchUser();
  }
});
</script>