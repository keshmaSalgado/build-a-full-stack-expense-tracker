import api from './api';

export const transactionService = {
  list: (params) => api.get('/api/transactions', { params }).then((res) => res.data),
  get: (id) => api.get(`/api/transactions/${id}`).then((res) => res.data),
  create: (payload) => api.post('/api/transactions', payload).then((res) => res.data),
  update: (id, payload) => api.put(`/api/transactions/${id}`, payload).then((res) => res.data),
  remove: (id) => api.delete(`/api/transactions/${id}`),
};
