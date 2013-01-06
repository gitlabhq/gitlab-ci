class AddScheduleToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :always_build, :boolean, :default => true
    add_column :projects, :polling_interval, :string
  end
end
