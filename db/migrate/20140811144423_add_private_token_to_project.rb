class AddPrivateTokenToProject < ActiveRecord::Migration
  def change
    add_column :projects, :private_token, :string
  end
end
