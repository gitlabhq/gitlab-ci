class AddProjectsTypeAndUserId < ActiveRecord::Migration
  def change
    add_column :projects, :type, :string
    add_column :projects, :user_id, :integer
  end
end
