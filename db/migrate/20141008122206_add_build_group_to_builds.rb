class AddBuildGroupToBuilds < ActiveRecord::Migration
  def change
    add_column :builds, :build_group_id, :integer
  end
end
