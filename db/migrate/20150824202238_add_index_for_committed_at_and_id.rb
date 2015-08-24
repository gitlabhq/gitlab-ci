class AddIndexForCommittedAtAndId < ActiveRecord::Migration
  def up
    add_index :commits, [:project_id, :committed_at, :id]
  end
end
