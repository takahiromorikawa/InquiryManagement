class Inquiry < ApplicationRecord
  # 1件の問い合わせに複数の返信が紐づく（1対多）。返信は投稿日時の古い順で扱う。
  has_many :replies, -> { order(created_at: :asc) }, dependent: :destroy

  # unhandled=未対応 / in_progress=対応中 / completed=対応済み
  enum :status, { unhandled: "unhandled", in_progress: "in_progress", completed: "completed" }

  validates :name, :email, :subject, :body, presence: true
end
