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
    <div class="page-head">
      <h1>問い合わせ一覧</h1>
      <p class="lead">受信したお問い合わせの一覧です。行を選択すると詳細を表示します。</p>
    </div>

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
.table-card {
  padding: 4px 0;
  overflow-x: auto;
}
table {
  width: 100%;
  border-collapse: collapse;
  font-size: 0.975rem;
}
th {
  text-align: left;
  font-size: 0.8rem;
  letter-spacing: 0.02em;
  color: var(--text-muted);
  font-weight: 600;
  padding: 12px 20px;
  border-bottom: 1px solid var(--border);
  white-space: nowrap;
}
td {
  padding: 15px 20px;
  border-bottom: 1px solid var(--border);
  vertical-align: middle;
}
tbody tr {
  cursor: pointer;
  transition: background 0.12s ease;
}
tbody tr:hover {
  background: var(--surface-muted);
}
tbody tr:last-child td {
  border-bottom: none;
}
.subject {
  font-weight: 600;
  color: var(--text);
}
.datetime {
  white-space: nowrap;
  color: var(--text-muted);
  font-size: 0.9rem;
}
</style>
