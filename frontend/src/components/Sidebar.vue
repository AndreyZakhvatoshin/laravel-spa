<template>
  <aside class="sidebar">
    <nav>
      <ul>
        <li><router-link to="/">Проекты</router-link></li>
        <li><router-link to="/about">О нас</router-link></li>
        <li><router-link to="/contacts">Контакты</router-link></li>
      </ul>
    </nav>
  </aside>
</template>

<style scoped>
.sidebar {
  width: 250px;
  background: #FAFAFBFF;
  color: white;
  padding: 1rem;
  box-sizing: border-box;
  height: 100vh;
  overflow-y: auto;
}

.sidebar a {
  color: #565D6DFF;
  text-decoration: none;
  display: block;
  margin-bottom: 0.5rem;
}
.sidebar a.router-link-exact-active {
  font-weight: bold;
}
</style>
