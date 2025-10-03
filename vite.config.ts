import {defineConfig} from 'vite'
import react from '@vitejs/plugin-react'

// https://vite.dev/config/
export default defineConfig({
    server: {
        allowedHosts: ['.ganymede'],
        proxy: {
            '/api/electric': {
                target: 'http://localhost:3000',
                changeOrigin: true,
                rewrite: (path) => path.replace(/^\/api\/electric/, ''),
            },
            '/api/v1': {
                target: 'http://localhost:5000',
                changeOrigin: true,
                rewrite: (path) => path.replace(/^\/api\/v1/, ''),
            },
            '/api/yjs': {
                target: 'ws://localhost:1234',
                ws: true,
                changeOrigin: true,
                rewrite: (path) => path.replace(/^\/api\/yjs/, ''),
            },

        }
    },
    plugins: [react()],
})
