<script setup>
import { computed } from 'vue'
import { RouterView, RouterLink, useRouter, useRoute } from 'vue-router'
import { useAuthStore } from './stores/auth'

const auth = useAuthStore()
const router = useRouter()
const route = useRoute()

// ロゴがホームリンクを兼ねる。ログイン中は問い合わせ一覧、未ログインは問い合わせフォームへ。
const homeLink = computed(() => (auth.isLoggedIn ? '/inquiries' : '/'))
const homeLabel = computed(() => (auth.isLoggedIn ? '問い合わせ一覧へ' : '問い合わせフォームへ'))

async function onLogout() {
  await auth.logout()
  router.push({ name: 'login' })
}
</script>

<template>
  <header class="appbar">
    <div class="appbar-inner">
      <RouterLink :to="homeLink" class="mark" :title="homeLabel" :aria-label="homeLabel">
        <svg viewBox="0 0 32 32" width="34" height="34" aria-hidden="true">
          <defs>
            <linearGradient id="g" x1="0" y1="0" x2="32" y2="32" gradientUnits="userSpaceOnUse">
              <stop stop-color="#6366f1" />
              <stop offset="1" stop-color="#4338ca" />
            </linearGradient>
          </defs>
          <rect x="0" y="0" width="32" height="32" rx="9" fill="url(#g)" />
          <path
            d="M11 10h10a3 3 0 0 1 3 3v5a3 3 0 0 1-3 3h-6.2l-3.5 2.8a.6.6 0 0 1-.97-.47V21h-.33A2 2 0 0 1 8 19V13a3 3 0 0 1 3-3Z"
            fill="#fff"
          />
          <circle cx="13" cy="15.5" r="1.3" fill="#4f46e5" />
          <circle cx="16" cy="15.5" r="1.3" fill="#4f46e5" />
          <circle cx="19" cy="15.5" r="1.3" fill="#4f46e5" />
        </svg>
      </RouterLink>

      <nav v-if="auth.isLoggedIn">
        <span class="user">
          <span class="avatar">{{ auth.staff?.name?.slice(0, 1) }}</span>
          <span class="user-name">{{ auth.staff?.name }}</span>
        </span>
        <button type="button" class="ghost nav-btn" @click="onLogout">ログアウト</button>
      </nav>
    </div>
  </header>

  <main>
    <RouterView />
  </main>

  <footer v-if="!auth.isLoggedIn && route.name !== 'login'" class="appfoot">
    <div class="appfoot-inner">
      <RouterLink to="/login" class="foot-link">担当者ログイン</RouterLink>
    </div>
  </footer>
</template>

<style scoped>
.appbar {
  position: sticky;
  top: 0;
  z-index: 20;
  background: rgba(255, 255, 255, 0.85);
  backdrop-filter: saturate(180%) blur(8px);
  border-bottom: 1px solid var(--border);
}
.appbar-inner {
  max-width: 960px;
  margin: 0 auto;
  padding: 12px 24px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 16px;
  min-height: 40px;
}
.mark {
  display: inline-flex;
  line-height: 0;
  border-radius: 9px;
  transition: opacity 0.15s ease;
}
.mark:hover {
  text-decoration: none;
  opacity: 0.82;
}
.mark:focus-visible {
  outline: 2px solid var(--primary);
  outline-offset: 3px;
}

nav {
  display: flex;
  align-items: center;
  gap: 8px;
}

.nav-btn {
  display: inline-flex;
  align-items: center;
  font-size: 0.95rem;
  font-weight: 600;
  padding: 8px 16px;
  min-height: 0;
  border-radius: var(--radius-sm);
  line-height: 1.5;
}

.user {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  padding-right: 4px;
}
.avatar {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 28px;
  height: 28px;
  border-radius: 50%;
  background: var(--primary-soft);
  color: var(--primary-hover);
  font-size: 0.85rem;
  font-weight: 700;
}
.user-name {
  font-size: 0.95rem;
  font-weight: 600;
}

main {
  flex: 1 0 auto;
  width: 100%;
  max-width: 960px;
  margin: 40px auto 56px;
  padding: 0 24px;
}

.appfoot {
  border-top: 1px solid var(--border);
  background: var(--surface);
}
.appfoot-inner {
  max-width: 960px;
  margin: 0 auto;
  padding: 18px 24px;
  display: flex;
  align-items: center;
  justify-content: flex-end;
  font-size: 0.85rem;
}
.foot-link {
  color: var(--text-muted);
  font-weight: 600;
}
.foot-link:hover {
  color: var(--primary);
}

@media (max-width: 560px) {
  .user-name {
    display: none;
  }
  .appbar-inner,
  main,
  .appfoot-inner {
    padding-inline: 16px;
  }
}
</style>
