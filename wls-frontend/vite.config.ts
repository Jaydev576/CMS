import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

// https://vite.dev/config/
export default defineConfig({
  plugins: [react()],
  server: {
    proxy: {
      "/wls": {
        target: "http://localhost:8081",
        changeOrigin: true,
        secure: false,
      },
      // Judge0 CE local — docker container on port 2358
      "/api": {
        target: "http://localhost:2358",
        changeOrigin: true,
        secure: false,
        rewrite: (path) => path.replace(/^\/api/, ""),
      },
    },
  },
})
