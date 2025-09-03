<template>
  <div id="app">
    <Sidebar />

    <div class="right-column">
      <AppHeader />

      <main class="main-content">
        <router-view />
      </main>

      <AppFooter :show-links="true" />
    </div>
  </div>
</template>

<script>
import AppHeader from './components/Header.vue'
import AppFooter from './components/Footer.vue'
import Sidebar from './components/Sidebar.vue'
import {createPinia} from 'pinia'

export default {
  name: 'App',
  components: {
    AppHeader,
    AppFooter,
    Sidebar
  },
  setup() {
    const pinia = createPinia()
    return {pinia}
  }
}
</script>

<style>
html, body, #app {
  margin: 0;
  height: 100vh;
  font-family: Arial, sans-serif;
}

/* Внешний контейнер - flex с двумя колонками */
#app {
  display: flex;
  height: 100vh;
  width: 100vw; /* чтобы занимал всю ширину окна */
  overflow: hidden;
}

/* Правая колонка - flex-контейнер по вертикали */
.right-column {
  flex: 1;
  display: flex;
  flex-direction: column;
  width: auto;
  height: 100vh;
  overflow: hidden;
}

/* Основной контейнер с прокруткой */
.main-content {
  flex: 1;
  overflow-y: auto;
  padding: 1rem;
}
</style>
