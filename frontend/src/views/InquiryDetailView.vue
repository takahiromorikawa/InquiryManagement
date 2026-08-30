<script setup lang="ts">
// S4: 問い合わせ詳細画面（UC4/UC5/UC6）
// この Issue ではルーティングの雛形のみ。詳細・返信・ステータス変更は後続 Issue。
defineProps<{ id: string }>()
</script>

<template>
  <section>
    <h1>問い合わせ詳細</h1>
    <p>ID: {{ id }}</p>
    <p>この画面は後続 Issue で実装します（S4 / GET /inquiries/:id ほか）。</p>
    <RouterLink to="/inquiries">← 一覧に戻る</RouterLink>
  </section>
</template>
