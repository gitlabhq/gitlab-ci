class MakeScriptNullable < ActiveRecord::Migration
  def change
    change_column :projects, :scripts, :text, null: true
  end
end