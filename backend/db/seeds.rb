# 担当者（Staff）の初期データ。担当者の登録・編集機能はスコープ外のため、seed で数件用意する。
# 冪等にするため find_or_create_by! を使う（パスワードは毎回設定する）。
#
#   bin/rails db:seed
#
staffs = [
  { name: "山田 太郎", email: "yamada@example.com" },
  { name: "佐藤 花子", email: "sato@example.com" },
  { name: "鈴木 一郎", email: "suzuki@example.com" },
]

staffs.each do |attrs|
  staff = Staff.find_or_initialize_by(email: attrs[:email])
  staff.name = attrs[:name]
  staff.password = "password"
  staff.save!
end

puts "Seeded #{Staff.count} staff members"
