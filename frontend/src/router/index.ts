import { createRouter, createWebHistory, type RouteRecordRaw } from 'vue-router'
import { useAuthStore } from '../stores/auth'

const routes: RouteRecordRaw[] = [
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
  { path: '/:pathMatch(.*)*', redirect: '/' },
]

const router = createRouter({
  history: createWebHistory(),
  routes,
})

// 未ログインで要ログイン画面にアクセスしたらログイン画面へ（UC2 代替フロー）
router.beforeEach((to) => {
  const auth = useAuthStore()
  if (!to.meta.public && !auth.isLoggedIn) {
    return { name: 'login', query: { redirect: to.fullPath } }
  }
})

export default router
