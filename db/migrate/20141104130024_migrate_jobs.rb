class MigrateJobs < ActiveRecord::Migration
  def change
    Project.find_each(batch_size: 100) do |project|
      job = project.jobs.create(commands: project.scripts)
      project.builds.update_all(job_id: job.id)
    end
  end
end
