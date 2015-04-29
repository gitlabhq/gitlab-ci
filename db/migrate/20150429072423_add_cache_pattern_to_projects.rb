class AddCachePatternToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :cache_pattern, :string, default: ''
  end
end
