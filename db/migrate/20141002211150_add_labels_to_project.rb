class AddLabelsToProject < ActiveRecord::Migration
  def change
    add_column :projects, :labels, :string
  end
end
