class AddExternUidToUsers < ActiveRecord::Migration
  def change
    add_column :users, :extern_uid, :string
  end
end
