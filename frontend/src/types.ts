// バックエンド（docs/api.md）のレスポンス形に対応する型。

export type InquiryStatus = 'unhandled' | 'in_progress' | 'completed'

export interface Staff {
  id: number
  name: string
  email: string
}

// GET /inquiries の各要素
export interface InquiryListItem {
  id: number
  subject: string
  name: string
  status: InquiryStatus
  created_at: string
}

export interface Reply {
  id: number
  body: string
  staff: string
  created_at: string
}

// GET /inquiries/:id / POST /inquiries / PATCH /inquiries/:id
export interface InquiryDetail {
  id: number
  name: string
  email: string
  subject: string
  body: string
  status: InquiryStatus
  created_at: string
  replies: Reply[]
}

export const STATUS_LABEL: Record<InquiryStatus, string> = {
  unhandled: '未対応',
  in_progress: '対応中',
  completed: '対応済み',
}
