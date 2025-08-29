import axios from 'axios';

const api = axios.create({
    baseURL: import.meta.env.VITE_API_URL,
    withCredentials: true, // Для Sanctum CSRF
});

export const register = async (credentials) => {
    const response = await api.post('api/register', credentials);
    return response.data;
};

export const login = async (credentials) => {
    const response = await api.post('/login', credentials);
    return response.data;
};

export const logout = async () => {
    const response = await api.post('/logout');
    return response.data;
};

export const getUser = async () => {
    const response = await api.get('/me');
    return response.data;
};

export default api;