<script setup>
// S5: 担当者管理画面（管理者のみ / UC8）
import { reactive, ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { api, ApiError } from '../lib/api'
import { useAuthStore } from '../stores/auth'

const auth = useAuthStore()
const router = useRouter()

const staffs = ref([])
const loading = ref(true)
const loadError = ref('')

const form = reactive({ name: '', email: '', password: '' })
const submitting = ref(false)
const formError = ref('')
const done = ref('')

// 401/403 を共通処理。処理したら true。
function handledAsDenied(e) {
  if (e instanceof ApiError && e.status === 401) {
    auth.clear()
    router.push({ name: 'login' })
    return true
  }
  if (e instanceof ApiError && e.status === 403) {
    router.push({ name: 'inquiry-list' })
    return true
  }
  return false
}

onMounted(async () => {
  try {
    staffs.value = await api.get('/staffs')
  } catch (e) {
    if (handledAsDenied(e)) return
    loadError.value = '担当者一覧の取得に失敗しました。'
  } finally {
    loading.value = false
  }
})

async function onSubmit() {
  formError.value = ''
  done.value = ''

  if (form.name.trim() === '' || form.email.trim() === '' || form.password === '') {
    formError.value = 'すべての項目を入力してください。'
    return
  }
  if (form.password.length < 8) {
    formError.value = 'パスワードは8文字以上で入力してください。'
    return
  }

  submitting.value = true
  try {
    const created = await api.post('/staffs', {
      name: form.name.trim(),
      email: form.email.trim(),
      password: form.password,
    })
    staffs.value.push(created)
    done.value = `${created.name} さんを追加しました。`
    form.name = ''
    form.email = ''
    form.password = ''
  } catch (e) {
    if (handledAsDenied(e)) return
    formError.value =
      e instanceof ApiError && e.status === 422
        ? (e.body?.errors?.[0] ?? '入力内容をご確認ください。')
        : '担当者の追加に失敗しました。'
  } finally {
    submitting.value = false
  }
}
</script>

<template>
  <section>
    <div class="page-head">
      <h1>担当者管理</h1>
      <p class="lead">担当者の一覧と追加ができます（管理者のみ）。</p>
    </div>

    <div class="card">
      <h2>担当者を追加</h2>
      <p v-if="done" class="alert success">{{ done }}</p>
      <p v-if="formError" class="alert error">{{ formError }}</p>

      <form @submit.prevent="onSubmit">
        <label class="field">
          <span>氏名</span>
          <input v-model="form.name" />
        </label>
        <label class="field">
          <span>メールアドレス</span>
          <input v-model="form.email" type="email" autocomplete="off" />
        </label>
        <label class="field">
          <span>パスワード（8文字以上）</span>
          <input v-model="form.password" type="password" autocomplete="new-password" />
        </label>
        <div class="actions">
          <button type="submit" :disabled="submitting">追加する</button>
        </div>
      </form>
    </div>

    <div class="card list-card">
      <h2>登録済みの担当者（{{ staffs.length }} 名）</h2>
      <p v-if="loading" class="note">読み込み中…</p>
      <p v-else-if="loadError" class="alert error">{{ loadError }}</p>
      <ul v-else class="staff-list">
        <li v-for="s in staffs" :key="s.id">
          <span class="staff-name">{{ s.name }}</span>
          <span class="staff-email">{{ s.email }}</span>
          <span v-if="s.admin" class="badge-admin">管理者</span>
        </li>
      </ul>
    </div>
  </section>
</template>

<style scoped>
.card + .card {
  margin-top: 20px;
}
h2 {
  font-size: 1.05rem;
  margin: 0 0 16px;
}
.note {
  color: var(--text-muted);
  font-size: 0.95rem;
}
.staff-list {
  list-style: none;
  padding: 0;
  margin: 0;
}
.staff-list li {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 12px 0;
  border-bottom: 1px solid var(--border);
}
.staff-list li:last-child {
  border-bottom: none;
}
.staff-name {
  font-weight: 600;
}
.staff-email {
  color: var(--text-muted);
  font-size: 0.9rem;
}
.badge-admin {
  margin-left: auto;
  font-size: 0.75rem;
  font-weight: 700;
  padding: 2px 10px;
  border-radius: 999px;
  background: var(--primary-soft);
  color: var(--primary-hover);
}
</style>
