import vue from '@vitejs/plugin-vue'
import { defineConfig } from 'vite'

// https://vite.dev/config/
export default defineConfig({
  plugins: [vue()],
  server: {
    // CLAUDE.md のポート管理ルール: フロントは 5173 固定。
    // 競合時に別ポートへ切り替えず、明示的に失敗させる。
    port: 5173,
    strictPort: true,
  },
})
