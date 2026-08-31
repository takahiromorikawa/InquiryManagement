class Staff < ApplicationRecord
  # パスワードは password_digest にハッシュ化して保存する（平文は保持しない）
  has_secure_password

  has_many :replies, dependent: :destroy

  validates :name, presence: true
  validates :email, presence: true, uniqueness: { case_sensitive: false }
  # has_secure_password が作成時の presence を担保する。ここでは長さのみ追加で検証する。
  validates :password, length: { minimum: 8 }, allow_nil: true

  # admin: true の担当者だけが他の担当者を追加できる（親権限）。
end
