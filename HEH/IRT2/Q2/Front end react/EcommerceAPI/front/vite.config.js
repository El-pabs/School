import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

// https://vite.dev/config/
export default defineConfig({
  plugins: [react()],
  test: {
    environement: 'jsdom',
    globals: true,
    setupFiles: ['./setup.js'],
  }
})
