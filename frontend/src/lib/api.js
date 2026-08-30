// バックエンド（Rails API）との通信をまとめる薄いラッパ。
// - ベースURLは VITE_API_BASE（未設定なら http://localhost:3000）
// - セッションCookieを送受信するため credentials: 'include' を常に付与
// - 401 は「未ログイン」として呼び出し側で扱えるよう ApiError.status で判別する

const BASE_URL = import.meta.env.VITE_API_BASE ?? 'http://localhost:3000'

export class ApiError extends Error {
  constructor(status, body) {
    super(`API request failed with status ${status}`)
    this.name = 'ApiError'
    this.status = status
    this.body = body
  }
}

async function request(method, path, body) {
  const res = await fetch(`${BASE_URL}${path}`, {
    method,
    credentials: 'include',
    headers: body === undefined ? {} : { 'Content-Type': 'application/json' },
    body: body === undefined ? undefined : JSON.stringify(body),
  })

  const text = await res.text()
  const data = text ? JSON.parse(text) : null

  if (!res.ok) {
    throw new ApiError(res.status, data)
  }
  return data
}

export const api = {
  get: (path) => request('GET', path),
  post: (path, body) => request('POST', path, body),
  patch: (path, body) => request('PATCH', path, body),
  delete: (path) => request('DELETE', path),
}
