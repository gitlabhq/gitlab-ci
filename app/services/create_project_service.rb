class CreateProjectService
  include Rails.application.routes.url_helpers

  def execute(current_user, params, project_route, forked_project = nil)
    @project = Project.parse(params)

    Project.transaction do
      @project.save!

      data = {
        token: @project.token,
        project_url: project_route.gsub(":project_id", @project.id.to_s),
      }

      auth_opts = if current_user.access_token
                    { access_token: current_user.access_token }
                  else
                    { private_token: current_user.private_token }
                  end

      unless Network.new.enable_ci(@project.gitlab_id, data, auth_opts)
        raise ActiveRecord::Rollback
      end
    end

    if forked_project
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
