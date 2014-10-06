class AddLabelsToBuild < ActiveRecord::Migration
  def change
    add_column :builds, :labels, :string
  end
end
