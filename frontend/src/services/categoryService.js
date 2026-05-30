import api from './api';

export const categoryService = {
  list: () => api.get('/api/categories').then((res) => res.data),
  create: (payload) => api.post('/api/categories', payload).then((res) => res.data),
  update: (id, payload) => api.put(`/api/categories/${id}`, payload).then((res) => res.data),
  remove: (id) => api.delete(`/api/categories/${id}`),
};
