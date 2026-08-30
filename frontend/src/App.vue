<script setup lang="ts">
import { RouterView, RouterLink, useRouter } from 'vue-router'
import { useAuthStore } from './stores/auth'

const auth = useAuthStore()
const router = useRouter()

async function onLogout() {
  await auth.logout()
  router.push({ name: 'login' })
}
</script>

<template>
  <header class="appbar">
    <RouterLink to="/" class="brand">InquiryManagement</RouterLink>
    <nav>
      <template v-if="auth.isLoggedIn">
        <span class="who">{{ auth.staff?.name }} でログイン中</span>
        <RouterLink to="/inquiries">問い合わせ一覧</RouterLink>
        <button type="button" @click="onLogout">ログアウト</button>
      </template>
      <template v-else>
        <RouterLink to="/">問い合わせフォーム</RouterLink>
        <RouterLink to="/login">担当者ログイン</RouterLink>
      </template>
    </nav>
  </header>

  <main>
    <RouterView />
  </main>
</template>

<style scoped>
.appbar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 12px 24px;
  border-bottom: 1px solid #e2e6ea;
}
.brand {
  font-weight: 700;
  text-decoration: none;
  color: inherit;
}
nav {
  display: flex;
  align-items: center;
  gap: 14px;
  font-size: 14px;
}
.who {
  color: #647787;
  font-size: 13px;
}
main {
  max-width: 880px;
  margin: 32px auto;
  padding: 0 20px;
}
</style>
