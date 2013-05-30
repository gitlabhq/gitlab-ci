class Scheduler
  def perform
    projects = Project.where(always_build: true).all
    projects.each do |project|
      last_build_time = project.last_build.created_at
      interval = project.polling_interval
      if (last_build_time + interval.hours) < Time.now
        build = project.register_build(ref: project.tracked_refs.first)
      end
    end
  end
end
