# 担当者（Staff）の初期データ。
# 担当者の追加は管理者（admin: true）のみが行える。初期の管理者として山田太郎を用意し、
# 他はアプリ画面から山田太郎が追加する運用を想定する。
# 冪等にするため find_or_initialize_by を使う（パスワードは毎回設定する）。
#
#   bin/rails db:seed
#
staffs = [
  { name: "山田 太郎", email: "yamada@example.com", admin: true },
  { name: "佐藤 花子", email: "sato@example.com", admin: false },
  { name: "鈴木 一郎", email: "suzuki@example.com", admin: false },
]

staffs.each do |attrs|
  staff = Staff.find_or_initialize_by(email: attrs[:email])
  staff.name = attrs[:name]
  staff.admin = attrs[:admin]
  staff.password = "password"
  staff.save!
end

puts "Seeded #{Staff.count} staff members (admin: #{Staff.where(admin: true).pluck(:email).join(', ')})"
