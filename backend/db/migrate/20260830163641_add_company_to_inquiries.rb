class AddCompanyToInquiries < ActiveRecord::Migration[7.1]
  def up
    add_column :inquiries, :company, :string
    # 既存レコードを仮値で埋めてから NOT NULL 制約を付ける
    execute("UPDATE inquiries SET company = '（未登録）' WHERE company IS NULL")
    change_column_null :inquiries, :company, false
  end

  def down
    remove_column :inquiries, :company
  end
end
