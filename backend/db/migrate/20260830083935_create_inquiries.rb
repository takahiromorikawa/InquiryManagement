class CreateInquiries < ActiveRecord::Migration[7.1]
  def change
    create_table :inquiries do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.string :subject, null: false
      t.text :body, null: false
      # unhandled=未対応 / in_progress=対応中 / completed=対応済み。作成時は常に unhandled。
      t.string :status, null: false, default: "unhandled"

      t.timestamps
    end
  end
end
