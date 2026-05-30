import api from './api';

export const reportService = {
  summary: () => api.get('/api/reports/summary').then((res) => res.data),
  monthly: () => api.get('/api/reports/monthly').then((res) => res.data),
  categories: () => api.get('/api/reports/categories').then((res) => res.data),
  incomeVsExpense: (params) => api.get('/api/reports/income-vs-expense', { params }).then((res) => res.data),
};
