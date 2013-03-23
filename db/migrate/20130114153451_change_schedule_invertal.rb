class ChangeScheduleInvertal < ActiveRecord::Migration
  def up
    if ActiveRecord::Base.connection.instance_of?(ActiveRecord::ConnectionAdapters::PostgreSQLAdapter)
      connection.execute(%q{
        alter table projects
        alter column polling_interval
        type integer using cast(polling_interval as integer)
      }) 
    else
      change_column :projects, :polling_interval, :integer, null: true
    end
  end

  def down
    if ActiveRecord::Base.connection.instance_of?(ActiveRecord::ConnectionAdapters::PostgreSQLAdapter)
      connection.execute(%q{
        alter table projects
        alter column polling_interval
        type varchar using cast(polling_interval as varchar)
      }) 
    else
      change_column :projects, :polling_interval, :string, null: true
    end
  end
end
