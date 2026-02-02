/** @type {import('tailwindcss').Config} */
export default {
  content: ['./index.html', './src/**/*.{js,ts,jsx,tsx}'],
  theme: {
    extend: {
      colors: {
        sand: {
          50: '#fefdfb',
          100: '#fdf8f0',
          200: '#f5ead6',
          300: '#e8d5b5',
          400: '#d4b896',
          500: '#c4a373',
          600: '#a68553',
          700: '#8a6a3d',
          800: '#5c4528',
          900: '#3d2e1a',
        },
        damascus: {
          400: '#6b7280',
          500: '#4a5568',
          600: '#374151',
          700: '#1f2937',
        },
        terracotta: {
          400: '#e07a52',
          500: '#c4623a',
          600: '#a54e2b',
          700: '#8a3d1f',
        },
      },
      fontFamily: {
        sans: ['Inter', 'system-ui', '-apple-system', 'BlinkMacSystemFont', 'Segoe UI', 'Roboto', 'sans-serif'],
      },
      boxShadow: {
        'sand': '0 4px 14px 0 rgba(166, 133, 83, 0.15)',
        'sand-lg': '0 10px 40px 0 rgba(166, 133, 83, 0.2)',
      },
    },
  },
  plugins: [],
}
