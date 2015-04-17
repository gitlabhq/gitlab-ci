class CleanupTheBuildModel < ActiveRecord::Migration
  def change
    remove_column :builds, :push_data
    remove_column :builds, :before_sha
    remove_column :builds, :ref
    remove_column :builds, :sha
    remove_column :builds, :tmp_file
  end
end
