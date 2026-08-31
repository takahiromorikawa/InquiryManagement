<script setup>
// S4: 問い合わせ詳細画面（UC4 詳細・返信スレッド / UC5 返信投稿 / UC6 ステータス変更）
import { ref, reactive, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { api, ApiError } from '../lib/api'
import { useAuthStore } from '../stores/auth'
import { formatDateTime } from '../lib/format'
import { STATUS_LABEL } from '../constants'
import StatusBadge from '../components/StatusBadge.vue'

const props = defineProps({ id: { type: String, required: true } })

const auth = useAuthStore()
const router = useRouter()

const STATUS_OPTIONS = Object.entries(STATUS_LABEL).map(([value, label]) => ({ value, label }))

const inquiry = ref(null)
const loading = ref(true)
const loadError = ref('')

const statusUpdating = ref(false)
const statusNote = ref('')
const statusError = ref('')

const replyForm = reactive({ body: '' })
const replySubmitting = ref(false)
const replyError = ref('')

// 401 なら未ログイン扱いにしてログイン画面へ。処理済みなら true を返す。
function handledAsUnauthorized(e) {
  if (e instanceof ApiError && e.status === 401) {
    auth.clear()
    router.push({ name: 'login' })
    return true
  }
  return false
}

onMounted(async () => {
  try {
    inquiry.value = await api.get(`/inquiries/${props.id}`)
  } catch (e) {
    if (handledAsUnauthorized(e)) return
    loadError.value =
      e instanceof ApiError && e.status === 404
        ? '指定された問い合わせが見つかりません。'
        : '問い合わせの取得に失敗しました。'
  } finally {
    loading.value = false
  }
})

async function onChangeStatus(event) {
  const next = event.target.value
  const prev = inquiry.value.status
  if (next === prev) return

  statusError.value = ''
  statusNote.value = ''
  statusUpdating.value = true
  try {
    const updated = await api.patch(`/inquiries/${props.id}`, { status: next })
    inquiry.value = updated
    statusNote.value = '更新しました'
    setTimeout(() => (statusNote.value = ''), 2000)
  } catch (e) {
    if (handledAsUnauthorized(e)) return
    event.target.value = prev // 選択を元に戻す
    statusError.value = 'ステータスの更新に失敗しました。'
  } finally {
    statusUpdating.value = false
  }
}

async function onSubmitReply() {
  replyError.value = ''
  if (replyForm.body.trim() === '') {
    replyError.value = '返信内容を入力してください。'
    return
  }

  replySubmitting.value = true
  try {
    const reply = await api.post(`/inquiries/${props.id}/replies`, { body: replyForm.body.trim() })
    inquiry.value.replies.push(reply)
    replyForm.body = ''
  } catch (e) {
    if (handledAsUnauthorized(e)) return
    replyError.value =
      e instanceof ApiError && e.status === 422
        ? '返信内容を入力してください。'
        : '返信の投稿に失敗しました。'
  } finally {
    replySubmitting.value = false
  }
}
</script>

<template>
  <section>
    <RouterLink to="/inquiries" class="back">← 一覧に戻る</RouterLink>

    <p v-if="loading" class="note">読み込み中…</p>
    <p v-else-if="loadError" class="alert error">{{ loadError }}</p>

    <template v-else-if="inquiry">
      <div class="card">
        <h1>{{ inquiry.subject }}</h1>
        <dl class="meta">
          <dt>会社名</dt>
          <dd>{{ inquiry.company }}</dd>
          <dt>氏名</dt>
          <dd>{{ inquiry.name }}</dd>
          <dt>メール</dt>
          <dd>{{ inquiry.email }}</dd>
          <dt>受信日時</dt>
          <dd>{{ formatDateTime(inquiry.created_at) }}</dd>
        </dl>
        <p class="body">{{ inquiry.body }}</p>

        <div class="status-row">
          <span class="status-label">ステータス</span>
          <StatusBadge :status="inquiry.status" />
          <select :value="inquiry.status" :disabled="statusUpdating" @change="onChangeStatus">
            <option v-for="o in STATUS_OPTIONS" :key="o.value" :value="o.value">{{ o.label }}</option>
          </select>
          <span v-if="statusNote" class="status-note">{{ statusNote }}</span>
        </div>
        <p v-if="statusError" class="alert error">{{ statusError }}</p>
      </div>

      <div class="card">
        <h2>返信スレッド（{{ inquiry.replies.length }} 件）</h2>

        <ul v-if="inquiry.replies.length" class="thread">
          <li v-for="r in inquiry.replies" :key="r.id">
            <div class="reply-head">
              <span class="staff">{{ r.staff }}</span>
              <span>{{ formatDateTime(r.created_at) }}</span>
            </div>
            <p class="reply-body">{{ r.body }}</p>
          </li>
        </ul>
        <p v-else class="note">まだ返信はありません。</p>

        <form @submit.prevent="onSubmitReply">
          <label class="field">
            <span>返信内容</span>
            <textarea v-model="replyForm.body" />
          </label>
          <p v-if="replyError" class="alert error">{{ replyError }}</p>
          <div class="actions">
            <button type="submit" :disabled="replySubmitting">返信する</button>
          </div>
        </form>
      </div>
    </template>
  </section>
</template>

<style scoped>
.back {
  display: inline-block;
  font-size: 0.9rem;
  font-weight: 600;
  color: var(--text-muted);
  margin-bottom: 18px;
}
.back:hover {
  color: var(--text);
  text-decoration: none;
}
.card + .card {
  margin-top: 20px;
}
h2 {
  font-size: 1.05rem;
  margin: 0 0 16px;
}
.meta {
  display: grid;
  grid-template-columns: max-content 1fr;
  gap: 6px 20px;
  font-size: 0.95rem;
  margin: 12px 0 16px;
}
.meta dt {
  color: var(--text-muted);
}
.meta dd {
  margin: 0;
}
.body {
  background: var(--surface-muted);
  border-radius: var(--radius-sm);
  padding: 16px 18px;
  font-size: 0.975rem;
  line-height: 1.8;
  white-space: pre-wrap;
  margin: 0;
}
.status-row {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-top: 22px;
  flex-wrap: wrap;
}
.status-label {
  font-size: 0.9rem;
  font-weight: 600;
}
.status-row select {
  padding: 8px 12px;
  border: 1px solid var(--border-strong);
  border-radius: var(--radius-sm);
  font: inherit;
  font-size: 0.95rem;
  background: var(--surface);
}
.status-row select:focus {
  outline: none;
  border-color: var(--primary);
  box-shadow: 0 0 0 4px var(--primary-soft);
}
.status-note {
  font-size: 0.85rem;
  font-weight: 600;
  color: var(--success);
}
.thread {
  list-style: none;
  padding: 0;
  margin: 0 0 20px;
  display: flex;
  flex-direction: column;
  gap: 12px;
}
.thread li {
  border: 1px solid var(--border);
  border-radius: var(--radius);
  padding: 14px 16px;
  background: var(--surface);
}
.reply-head {
  display: flex;
  justify-content: space-between;
  align-items: baseline;
  font-size: 0.85rem;
  color: var(--text-muted);
  margin-bottom: 6px;
}
.reply-head .staff {
  font-weight: 700;
  font-size: 0.95rem;
  color: var(--text);
}
.reply-body {
  font-size: 0.975rem;
  line-height: 1.8;
  white-space: pre-wrap;
  margin: 0;
}
</style>
