class IncreateTraceColunmLimit < ActiveRecord::Migration
  def up
    change_column :builds, :trace, :text, :limit => 4294967295
  end

  def down
  end
end
