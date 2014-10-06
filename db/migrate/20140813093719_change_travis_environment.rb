class ChangeTravisEnvironment < ActiveRecord::Migration
  def change
    change_column :projects, :travis_environment, :text, :limit => 65536
  end
end
