class IncreateTraceColunmLimit < ActiveRecord::Migration
  def up
    if ActiveRecord::Base.connection.instance_of?(ActiveRecord::ConnectionAdapters::PostgreSQLAdapter)
      change_column :builds, :trace, :text
    else
      change_column :builds, :trace, :text, :limit => 4294967295
    end
  end

  def down
  end
end
