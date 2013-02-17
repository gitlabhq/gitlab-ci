class AddProjectsGitUrlAndPublicKeyAndPrivateKey < ActiveRecord::Migration
  def change
    add_column :projects, :clone_url, :string
    add_column :projects, :private_key, :text
    add_column :projects, :public_key, :text
    add_column :projects, :github_repo_id, :integer
  end
end
