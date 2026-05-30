export default {
  darkMode: 'class',
  content: ['./index.html', './src/**/*.{js,jsx}'],
  theme: {
    extend: {
      colors: {
        ink: '#111827',
        mint: '#10b981',
        coral: '#f97316',
        berry: '#be123c',
      },
      boxShadow: {
        soft: '0 18px 50px rgba(15, 23, 42, 0.10)',
      },
    },
  },
  plugins: [],
};
