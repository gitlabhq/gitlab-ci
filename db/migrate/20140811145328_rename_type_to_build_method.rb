class RenameTypeToBuildMethod < ActiveRecord::Migration
  def change
    rename_column :projects, :type, :build_method
    rename_column :builds, :type, :build_method
  end
end
