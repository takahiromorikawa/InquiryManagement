class CreateReplies < ActiveRecord::Migration[7.1]
  def change
    create_table :replies do |t|
      t.references :inquiry, null: false, foreign_key: true
      t.references :staff, null: false, foreign_key: true
      t.text :body, null: false

      t.timestamps
    end
  end
end
