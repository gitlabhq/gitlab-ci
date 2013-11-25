class Scheduler
  def perform
    projects = Project.where(always_build: true).all
    projects.each do |project|
      last_build = project.last_build
      next unless last_build

      interval = project.polling_interval
      if (last_build.created_at + interval.hours) < Time.now
        Build.create_from(last_build)
      end
    end
  end
end
