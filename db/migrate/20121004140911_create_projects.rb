class CreateProjects < ActiveRecord::Migration
  def up
    create_table :projects do |t|
      t.string :name
      t.string :path
      t.text :scripts
      t.timestamps
    end
  end

  def down
  end
end
