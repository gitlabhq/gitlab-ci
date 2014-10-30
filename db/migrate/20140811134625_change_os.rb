class ChangeOs < ActiveRecord::Migration
  def change
    change_column :builds, :os, :string, default: 'shell'
  end
end
