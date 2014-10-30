class Scheduler
  def perform
    projects = Project.where(always_build: true).all
    projects.each do |project|
      last_build = project.last_build
      next unless last_build

      interval = project.polling_interval
      if (last_build.created_at + interval.hours) < Time.now
        CreateBuildService.new.execute(project, last_build)
        puts "."
      end
    end
  end
end
