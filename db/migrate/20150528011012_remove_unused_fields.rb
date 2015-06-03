class RemoveUnusedFields < ActiveRecord::Migration
  def up
    select_all("SELECT id, name FROM jobs").each do |job|
      execute("UPDATE builds SET name = '#{quote_string(job["name"])}' WHERE job_id = #{job["id"]}")
    end

    remove_column :builds, :job_id, :integer
  end

  def down
    add_column :builds, :job_id, :integer
  end
end
