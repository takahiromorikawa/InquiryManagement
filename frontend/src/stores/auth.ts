import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { api } from '../lib/api'
import type { Staff } from '../types'

const STORAGE_KEY = 'inquiry_management_staff'

// バックエンドにセッション確認用エンドポイントが無いため、ログイン中の担当者情報は
// sessionStorage にミラーしておき、リロード後もルートガードを通す。
// 実際の認可はサーバー側セッションが担い、API が 401 を返したらここをクリアする。
function loadStaff(): Staff | null {
  try {
    const raw = sessionStorage.getItem(STORAGE_KEY)
    return raw ? (JSON.parse(raw) as Staff) : null
  } catch {
    return null
  }
}

export const useAuthStore = defineStore('auth', () => {
  const staff = ref<Staff | null>(loadStaff())
  const isLoggedIn = computed(() => staff.value !== null)

  function setStaff(value: Staff | null) {
    staff.value = value
    try {
      if (value) sessionStorage.setItem(STORAGE_KEY, JSON.stringify(value))
      else sessionStorage.removeItem(STORAGE_KEY)
    } catch {
      /* sessionStorage が使えない環境ではメモリ状態のみで動作させる */
    }
  }

  async function login(email: string, password: string) {
    const me = await api.post<Staff>('/login', { email, password })
    setStaff(me)
  }

  async function logout() {
    try {
      await api.delete('/logout')
    } finally {
      setStaff(null)
    }
  }

  // API が 401 を返したときに呼ぶ（セッション切れ）
  function clear() {
    setStaff(null)
  }

  return { staff, isLoggedIn, login, logout, clear }
})
