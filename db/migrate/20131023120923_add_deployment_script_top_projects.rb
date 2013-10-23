class AddDeploymentScriptTopProjects < ActiveRecord::Migration
  def change
    add_column :projects, :deployment_script, :string
  end
end
