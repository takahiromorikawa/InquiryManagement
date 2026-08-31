<script setup>
// S1: 問い合わせフォーム画面（顧客向け・ログイン不要 / UC1）
import { reactive, ref } from 'vue'
import { api, ApiError } from '../lib/api'

const form = reactive({ company: '', name: '', email: '', subject: '', body: '' })

const submitting = ref(false)
const error = ref('')
const done = ref(false)

const FIELDS = [
  { key: 'company', label: '会社名', type: 'input' },
  { key: 'name', label: '氏名', type: 'input' },
  { key: 'email', label: 'メールアドレス', type: 'input', inputType: 'email' },
  { key: 'subject', label: '件名', type: 'input' },
  { key: 'body', label: '内容', type: 'textarea' },
]

async function onSubmit() {
  error.value = ''
  done.value = false

  if (FIELDS.some(({ key }) => form[key].trim() === '')) {
    error.value = 'すべての項目を入力してください。'
    return
  }

  submitting.value = true
  try {
    await api.post('/inquiries', {
      company: form.company.trim(),
      name: form.name.trim(),
      email: form.email.trim(),
      subject: form.subject.trim(),
      body: form.body.trim(),
    })
    done.value = true
    FIELDS.forEach(({ key }) => (form[key] = ''))
  } catch (e) {
    error.value =
      e instanceof ApiError && e.status === 422
        ? '入力内容をご確認ください。'
        : '送信に失敗しました。時間をおいて再度お試しください。'
  } finally {
    submitting.value = false
  }
}
</script>

<template>
  <section>
    <div class="page-head">
      <h1>お問い合わせ</h1>
      <p class="lead">
        ご質問・ご依頼内容をご記入のうえ送信してください。担当者より折り返しご連絡します。
      </p>
    </div>

    <div class="card">
      <p v-if="done" class="alert success">
        お問い合わせを送信しました。担当者からの連絡をお待ちください。
      </p>
      <p v-if="error" class="alert error">{{ error }}</p>

      <form @submit.prevent="onSubmit">
        <label v-for="f in FIELDS" :key="f.key" class="field">
          <span>{{ f.label }}</span>
          <textarea v-if="f.type === 'textarea'" v-model="form[f.key]" />
          <input v-else v-model="form[f.key]" :type="f.inputType ?? 'text'" />
        </label>

        <div class="actions">
          <button type="submit" :disabled="submitting">送信</button>
        </div>
      </form>
    </div>
  </section>
</template>

