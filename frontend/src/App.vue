<template>
  <Header />
  <main class="p-4">
    <router-view />
  </main>
  <Footer />
</template>

<script setup>
import Header from './components/Header.vue'
import Footer from './components/Footer.vue'
</script>

<style>
body {
  font-family: sans-serif;
  margin: 0;
  padding: 0;
}
main {
  min-height: 70vh;
}
</style>
