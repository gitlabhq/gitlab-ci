class AddRefMessageToBuilds < ActiveRecord::Migration
  def change
    add_column :builds, :ref_message, :string
    add_column :build_groups, :ref_message, :string
  end
end
