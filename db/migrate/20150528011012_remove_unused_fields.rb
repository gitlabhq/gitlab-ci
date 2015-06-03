class RemoveUnusedFields < ActiveRecord::Migration
  def change
    remove_column :builds, :job_id, :integer
  end
end
