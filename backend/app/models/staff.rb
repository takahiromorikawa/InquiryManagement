class Staff < ApplicationRecord
  # パスワードは password_digest にハッシュ化して保存する（平文は保持しない）
  has_secure_password

  has_many :replies, dependent: :destroy

  validates :name, presence: true
  validates :email, presence: true, uniqueness: { case_sensitive: false }
end
