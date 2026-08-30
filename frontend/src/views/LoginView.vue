<script setup lang="ts">
// S2: ログイン画面（UC2）。疎通確認のため最小限の実装を入れている。
import { ref } from 'vue'
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

async function onSubmit() {
  error.value = ''
  submitting.value = true
  try {
    await auth.login(email.value, password.value)
    const redirect = typeof route.query.redirect === 'string' ? route.query.redirect : '/inquiries'
    router.push(redirect)
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
    <h1>担当者ログイン</h1>
    <p v-if="error" class="error">{{ error }}</p>
    <form @submit.prevent="onSubmit">
      <label>
        メールアドレス
        <input v-model="email" type="email" autocomplete="username" />
      </label>
      <label>
        パスワード
        <input v-model="password" type="password" autocomplete="current-password" />
      </label>
      <button type="submit" :disabled="submitting">ログイン</button>
    </form>
    <p class="hint">
      seed アカウント: yamada@example.com / sato@example.com / suzuki@example.com（パスワード: password）
    </p>
  </section>
</template>

<style scoped>
.login {
  max-width: 360px;
}
form {
  display: flex;
  flex-direction: column;
  gap: 12px;
}
label {
  display: flex;
  flex-direction: column;
  gap: 4px;
  font-size: 13px;
  font-weight: 600;
}
input {
  padding: 8px 10px;
  border: 1px solid #d0d7de;
  border-radius: 6px;
  font: inherit;
}
button {
  padding: 9px 16px;
  font: inherit;
  font-weight: 600;
}
.error {
  color: #dc2626;
  font-size: 13px;
}
.hint {
  margin-top: 16px;
  font-size: 12px;
  color: #647787;
}
</style>
