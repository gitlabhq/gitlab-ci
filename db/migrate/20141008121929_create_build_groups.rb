class CreateBuildGroups < ActiveRecord::Migration
  def change
    create_table :build_groups do |t|
      t.integer :project_id
      t.string :ref
      t.string :ref_type
      t.string :sha
      t.string :before_sha
      t.text :push_data
      t.datetime :finished_at
      t.timestamps
    end
  end
end
