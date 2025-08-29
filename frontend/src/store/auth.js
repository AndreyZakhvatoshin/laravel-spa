import { defineStore } from 'pinia';
import { register, login, logout, getUser } from '../api/auth'; // Import all API functions

export const useAuthStore = defineStore('auth', {
    state: () => ({
        user: null,
        token: localStorage.getItem('token'),
    }),
    actions: {
        async register(credentials) {
            const response = await register(credentials); // Use the imported register function
            this.token = response.access_token;
            localStorage.setItem('token', this.token);
            // Assuming api is the axios instance from api/auth.js
            // If not, adjust the headers manually or import api
            // import api from '../api/auth'; api.defaults.headers.Authorization = `Bearer ${this.token}`;
            this.user = response.user;
        },
        async login(credentials) {
            const response = await login(credentials);
            this.token = response.access_token;
            localStorage.setItem('token', this.token);
            // api.defaults.headers.Authorization = `Bearer ${this.token}`; // Uncomment if needed
            this.user = response.user;
        },
        async logout() {
            await logout();
            this.token = null;
            this.user = null;
            localStorage.removeItem('token');
            // delete api.defaults.headers.Authorization; // Uncomment if needed
        },
        async fetchUser() {
            this.user = await getUser();
        },
    },
    getters: {
        isAuthenticated: (state) => !!state.token,
    },
});