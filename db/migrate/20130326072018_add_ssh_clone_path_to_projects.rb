class AddSshClonePathToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :ssh_clone_path, :string
  end
end
