class CreateProjectService
  include Rails.application.routes.url_helpers

  def execute(current_user, params, project_route)
    @project = Project.parse(params, current_user.private_token)
    @project.build_method = CreateBuildService.new.detect_build_method(@project)

    Project.transaction do
      @project.save!

      opts = {
        token: @project.token,
        project_url: project_route.gsub(":project_id", @project.id.to_s),
      }

      if Network.new.enable_ci(current_user.url, @project.gitlab_id, opts, current_user.private_token)
        true
      else
        raise ActiveRecord::Rollback
      end
    end

    @project
  end
end
