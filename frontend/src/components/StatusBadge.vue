<script setup>
// 問い合わせステータスのバッジ表示。S3 一覧・S4 詳細で共用。
import { STATUS_LABEL } from '../constants'

defineProps({
  status: {
    type: String,
    required: true,
    validator: (v) => v in STATUS_LABEL,
  },
})
</script>

<template>
  <span class="badge" :class="status">{{ STATUS_LABEL[status] }}</span>
</template>

<style scoped>
.badge {
  display: inline-block;
  font-size: 12px;
  font-weight: 600;
  padding: 2px 10px;
  border-radius: 999px;
  white-space: nowrap;
}
.badge.unhandled {
  background: #fef3c7;
  color: #92400e;
}
.badge.in_progress {
  background: #dbeafe;
  color: #1e40af;
}
.badge.completed {
  background: #dcfce7;
  color: #166534;
}
</style>
