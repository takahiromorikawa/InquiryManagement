import { createRouter, createWebHistory } from 'vue-router'
import { useAuthStore } from '../stores/auth'

const routes = [
  {
    path: '/',
    name: 'inquiry-form',
    component: () => import('../views/InquiryFormView.vue'),
    meta: { public: true }, // S1: 顧客向け・ログイン不要
  },
  {
    path: '/login',
    name: 'login',
    component: () => import('../views/LoginView.vue'),
    meta: { public: true }, // S2
  },
  {
    path: '/inquiries',
    name: 'inquiry-list',
    component: () => import('../views/InquiryListView.vue'), // S3: 要ログイン
  },
  {
    path: '/inquiries/:id',
    name: 'inquiry-detail',
    component: () => import('../views/InquiryDetailView.vue'), // S4: 要ログイン
    props: true,
  },
  {
    path: '/staffs',
    name: 'staff-list',
    component: () => import('../views/StaffListView.vue'), // S5: 管理者のみ
    meta: { admin: true },
  },
  { path: '/:pathMatch(.*)*', redirect: '/' },
]

const router = createRouter({
  history: createWebHistory(),
  routes,
})

router.beforeEach((to) => {
  const auth = useAuthStore()

  // 未ログインで要ログイン画面にアクセスしたらログイン画面へ（UC2 代替フロー）
  if (!to.meta.public && !auth.isLoggedIn) {
    return { name: 'login', query: { redirect: to.fullPath } }
  }

  // 管理者専用画面に一般担当者がアクセスしたら一覧へ
  if (to.meta.admin && !auth.isAdmin) {
    return { name: 'inquiry-list' }
  }
})

export default router
