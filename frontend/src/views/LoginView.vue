<script setup>
// S2: ログイン画面（UC2）
import { ref, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { useAuthStore } from '../stores/auth'
import { ApiError } from '../lib/api'

const auth = useAuthStore()
const router = useRouter()
const route = useRoute()

const email = ref('')
const password = ref('')
const error = ref('')
const submitting = ref(false)

function redirectTarget() {
  const { redirect } = route.query
  return typeof redirect === 'string' && redirect.startsWith('/') ? redirect : '/inquiries'
}

// すでにログイン済みならログイン画面を表示しない
onMounted(() => {
  if (auth.isLoggedIn) router.replace(redirectTarget())
})

async function onSubmit() {
  error.value = ''
  submitting.value = true
  try {
    await auth.login(email.value.trim(), password.value)
    router.replace(redirectTarget())
  } catch (e) {
    error.value =
      e instanceof ApiError && e.status === 401
        ? 'メールアドレスまたはパスワードが正しくありません。'
        : '通信に失敗しました。時間をおいて再度お試しください。'
  } finally {
    submitting.value = false
  }
}
</script>

<template>
  <section class="login">
    <div class="page-head">
      <h1>担当者ログイン</h1>
      <p class="lead">メールアドレスとパスワードでログインしてください。</p>
    </div>

    <div class="card">
      <p v-if="error" class="alert error">{{ error }}</p>

      <form @submit.prevent="onSubmit">
        <label class="field">
          <span>メールアドレス</span>
          <input v-model="email" type="email" autocomplete="username" required />
        </label>
        <label class="field">
          <span>パスワード</span>
          <input v-model="password" type="password" autocomplete="current-password" required />
        </label>

        <div class="actions">
          <button type="submit" :disabled="submitting">
            {{ submitting ? 'ログイン中…' : 'ログイン' }}
          </button>
        </div>
      </form>

      <p class="hint">
        seed アカウント: yamada@example.com / sato@example.com / suzuki@example.com<br />
        パスワードはいずれも <code>password</code>
      </p>
    </div>
  </section>
</template>

<style scoped>
.login {
  max-width: 420px;
  margin: 24px auto 0;
}
.hint {
  margin: 18px 0 0;
  font-size: 0.85rem;
  color: var(--text-muted);
  line-height: 1.8;
}
.hint code {
  background: var(--surface-muted);
  padding: 1px 6px;
  border-radius: 4px;
  font-size: 0.85em;
}
</style>
