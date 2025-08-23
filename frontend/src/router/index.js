import { createRouter, createWebHistory } from 'vue-router'
import About from '../views/About.vue'
import Home from '../views/Home.vue';
import Register from '../views/Register.vue'

const routes = [
  { path: '/', component: Home },
  { path: '/about', component: About },
  { path: '/register', name: 'Register', component: Register },
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

export default router