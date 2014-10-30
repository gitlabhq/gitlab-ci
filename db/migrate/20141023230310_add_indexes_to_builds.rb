class AddIndexesToBuilds < ActiveRecord::Migration
  def change
    add_index :build_groups, :ref_type
    add_index :build_groups, [:project_id, :ref_type]
    add_index :build_groups, [:project_id, :id]
    add_index :builds, :ref_type
    add_index :builds, [:project_id, :ref_type]
    add_index :builds, [:project_id, :id]
    add_index :builds, :build_group_id
    add_index :builds, [:build_group_id, :id]
    add_index :builds, [:build_group_id, :project_id, :id]
    add_index :builds, :build_os
    add_index :builds, :build_image
  end
end
