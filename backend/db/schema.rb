# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2026_08_30_083937) do
  create_table "inquiries", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.string "subject", null: false
    t.text "body", null: false
    t.string "status", default: "unhandled", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "replies", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "inquiry_id", null: false
    t.bigint "staff_id", null: false
    t.text "body", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["inquiry_id"], name: "index_replies_on_inquiry_id"
    t.index ["staff_id"], name: "index_replies_on_staff_id"
  end

  create_table "staffs", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_staffs_on_email", unique: true
  end

  add_foreign_key "replies", "inquiries"
  add_foreign_key "replies", "staffs"
end
