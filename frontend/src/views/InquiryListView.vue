<script setup>
// S3: 問い合わせ一覧画面（UC3）
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { api, ApiError } from '../lib/api'
import { useAuthStore } from '../stores/auth'
import { formatDateTime } from '../lib/format'
import StatusBadge from '../components/StatusBadge.vue'

const inquiries = ref([])
const loading = ref(true)
const error = ref('')
const auth = useAuthStore()
const router = useRouter()

onMounted(async () => {
  try {
    inquiries.value = await api.get('/inquiries')
  } catch (e) {
    if (e instanceof ApiError && e.status === 401) {
      auth.clear()
      router.push({ name: 'login' })
      return
    }
    error.value = '一覧の取得に失敗しました。時間をおいて再度お試しください。'
  } finally {
    loading.value = false
  }
})

function openDetail(id) {
  router.push(`/inquiries/${id}`)
}
</script>

<template>
  <section>
    <h1>問い合わせ一覧</h1>

    <p v-if="loading" class="note">読み込み中…</p>
    <p v-else-if="error" class="alert error">{{ error }}</p>
    <p v-else-if="inquiries.length === 0" class="note">問い合わせはまだありません。</p>

    <div v-else class="card table-card">
      <table>
        <thead>
          <tr>
            <th>件名</th>
            <th>送信者</th>
            <th>ステータス</th>
            <th>受信日時</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="i in inquiries" :key="i.id" @click="openDetail(i.id)">
            <td class="subject">{{ i.subject }}</td>
            <td>{{ i.name }}</td>
            <td><StatusBadge :status="i.status" /></td>
            <td class="datetime">{{ formatDateTime(i.created_at) }}</td>
          </tr>
        </tbody>
      </table>
    </div>
  </section>
</template>

<style scoped>
.note {
  color: var(--muted);
  font-size: 13px;
}
.table-card {
  padding: 0;
  overflow-x: auto;
}
table {
  width: 100%;
  border-collapse: collapse;
  font-size: 14px;
}
th {
  text-align: left;
  font-size: 12px;
  color: var(--muted);
  font-weight: 600;
  padding: 10px 14px;
  border-bottom: 1px solid var(--border);
  white-space: nowrap;
}
td {
  padding: 12px 14px;
  border-bottom: 1px solid var(--border);
}
tbody tr {
  cursor: pointer;
}
tbody tr:hover {
  background: #f8fafc;
}
tbody tr:last-child td {
  border-bottom: none;
}
.subject {
  font-weight: 600;
}
.datetime {
  white-space: nowrap;
  color: var(--muted);
}
</style>
