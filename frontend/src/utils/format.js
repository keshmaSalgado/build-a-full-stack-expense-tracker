export const formatCurrency = (value, currency = 'USD') =>
  new Intl.NumberFormat('en-US', { style: 'currency', currency }).format(Number(value || 0));

export const monthLabel = (month, year) =>
  new Intl.DateTimeFormat('en', { month: 'short', year: '2-digit' }).format(new Date(year, month - 1, 1));
