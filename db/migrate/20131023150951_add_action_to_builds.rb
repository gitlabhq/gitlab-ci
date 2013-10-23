class AddActionToBuilds < ActiveRecord::Migration
  def change
    add_column :builds, :action, :string
  end
end
