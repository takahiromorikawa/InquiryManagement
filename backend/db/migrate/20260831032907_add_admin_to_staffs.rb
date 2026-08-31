class AddAdminToStaffs < ActiveRecord::Migration[7.1]
  def change
    add_column :staffs, :admin, :boolean, null: false, default: false
  end
end
