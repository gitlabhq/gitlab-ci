class CreateProjectService
  include Rails.application.routes.url_helpers

  def execute(current_user, params, project_route, forked_project = nil)
    @project = Project.parse(params)

    Project.transaction do
      @project.build_default_job
      @project.save!

      opts = {
        token: @project.token,
        project_url: project_route.gsub(":project_id", @project.id.to_s),
      }

      unless Network.new.enable_ci(@project.gitlab_id, opts, current_user.private_token)
        raise ActiveRecord::Rollback
      end
    end

    if forked_project
      # Copy jobs
      @project.jobs = forked_project.jobs.map do |job|
        Job.new(job.attributes.except("id"))
      end

      # Copy settings
      settings = forked_project.attributes.select do |attr_name, value|
        ["public", "shared_runners_enabled", "allow_git_fetch"].include? attr_name
      end

      @project.update(settings)
    end

    EventService.new.create_project(current_user, @project)

    @project
  end
end
