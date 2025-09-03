import { defineStore } from 'pinia'
import axios from 'axios'

export const useAuthStore = defineStore('auth', {
    state: () => ({
        isAuthenticated: false,
        user: {
            name: '',
            avatar: 'https://via.placeholder.com/32'
        },
        token: null
    }),
    actions: {
        async register(userData) {
            try {
                // Отправляем запрос на регистрацию
                const response = await axios.post('/api/register', userData);

                // Сохраняем токен
                this.token = response.data.token;
                localStorage.setItem('token', response.data.token);

                // Устанавливаем данные пользователя
                this.setUserData({
                    name: userData.name,
                    // Здесь можно добавить другие данные из ответа
                });

                // Помечаем как аутентифицированного
                this.isAuthenticated = true;

                return response;
            } catch (error) {
                // Пробрасываем ошибку дальше для обработки в компоненте
                throw error;
            }
        },

        async login(userData) {
            try {
                const response = await axios.post('/api/login', userData);

                this.token = response.data.token;
                localStorage.setItem('token', response.data.token);

                this.setUserData({
                    name: userData.email,
                });

                this.isAuthenticated = true;

                return response;
            } catch (error) {
                throw error;
            }
        },

        logout() {
            localStorage.removeItem('token');
            this.token = null;
            this.isAuthenticated = false;
            this.user = {
                name: '',
                avatar: 'https://via.placeholder.com/32'
            };
        },

        setUserData(userData) {
            this.user = { ...this.user, ...userData };
        }
    },
    getters: {
        userName: (state) => state.user.name,
        userAvatar: (state) => state.user.avatar
    }
});