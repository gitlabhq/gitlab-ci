class RenameAttributesToBuildAttributes < ActiveRecord::Migration
  def change
    rename_column :builds, :attributes, :build_attributes
  end
end
