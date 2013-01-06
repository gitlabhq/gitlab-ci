class SchedulerJob
  @queue = :scheduler_task

  def self.perform(method, *args)
    self.send(method, *args)
  end

  # run scheduler job
  def self.run(project_id)
    @project = Project.find(project_id)

    # when always_build not checked, do not build project in schedule if project not updated
    return if !@project.always_build && (@project.builds.last.sha == @project.last_ref_sha(@project.default_ref))

    # always_build not checked and project updated, build it
    # always_build checked and no matter project updated or not, build it
    @build = @project.register_build(ref: @project.default_ref)
    if @build and @build.id
      Runner.new(Build.find(@build.id)).run
    end
  end
end
