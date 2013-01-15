class ChangeScheduleInvertal < ActiveRecord::Migration
  def up
    change_column :projects, :polling_interval, :integer, null: true
  end

  def down
    change_column :projects, :polling_interval, :string, null: true
  end
end
