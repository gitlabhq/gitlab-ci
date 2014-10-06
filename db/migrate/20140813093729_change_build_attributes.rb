class ChangeBuildAttributes < ActiveRecord::Migration
  def change
    change_column :builds, :build_attributes, :text, :limit => 65536
    change_column :builds, :matrix_attributes, :text, :limit => 65536
  end
end
