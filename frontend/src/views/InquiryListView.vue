<script setup lang="ts">
// S3: 問い合わせ一覧画面（UC3）。この Issue では API 疎通確認のため
// GET /inquiries を呼び、件数と件名だけを表示する。表組み等は後続 Issue。
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { api, ApiError } from '../lib/api'
import { useAuthStore } from '../stores/auth'
import { STATUS_LABEL, type InquiryListItem } from '../types'

const inquiries = ref<InquiryListItem[]>([])
const loading = ref(true)
const error = ref('')
const auth = useAuthStore()
const router = useRouter()

onMounted(async () => {
  try {
    inquiries.value = await api.get<InquiryListItem[]>('/inquiries')
  } catch (e) {
    if (e instanceof ApiError && e.status === 401) {
      auth.clear()
      router.push({ name: 'login' })
      return
    }
    error.value = '一覧の取得に失敗しました。'
  } finally {
    loading.value = false
  }
})
</script>

<template>
  <section>
    <h1>問い合わせ一覧</h1>
    <p v-if="loading">読み込み中…</p>
    <p v-else-if="error" class="error">{{ error }}</p>
    <template v-else>
      <p>{{ inquiries.length }} 件（API 疎通確認用の暫定表示）</p>
      <ul>
        <li v-for="i in inquiries" :key="i.id">
          <RouterLink :to="`/inquiries/${i.id}`">{{ i.subject }}</RouterLink>
          — {{ i.name }} / {{ STATUS_LABEL[i.status] }}
        </li>
      </ul>
    </template>
  </section>
</template>

<style scoped>
.error {
  color: #dc2626;
}
ul {
  padding-left: 18px;
}
li {
  margin: 6px 0;
}
</style>
