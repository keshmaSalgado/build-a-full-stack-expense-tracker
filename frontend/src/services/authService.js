import api from './api';

export const authService = {
  register: (payload) => api.post('/api/auth/register', payload).then((res) => res.data),
  login: (payload) => api.post('/api/auth/login', payload).then((res) => res.data),
  me: () => api.get('/api/users/me').then((res) => res.data),
  updateProfile: (payload) => api.put('/api/users/me', payload).then((res) => res.data),
};
