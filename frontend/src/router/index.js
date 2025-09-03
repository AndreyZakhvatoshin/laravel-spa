import { createRouter, createWebHistory } from 'vue-router';
import Register from '../views/Register.vue';
import Login from '../views/Login.vue';
import Profile from '../views/Profile.vue';
import Home from "../views/Home.vue";
import { useAuthStore } from '../store/auth';

const routes = [
  { path: '/register', component: Register },
  { path: '/login', component: Login },
  {
    path: '/profile',
    component: Profile,
    meta: { requiresAuth: true },
  },
  { path: '/', component: Home },
];

const router = createRouter({
  history: createWebHistory(),
  routes,
});

router.beforeEach((to, from, next) => {
  const authStore = useAuthStore();
  if (to.meta.requiresAuth && !authStore.isAuthenticated) {
    next('/login');
  } else {
    next();
  }
});

export default router;