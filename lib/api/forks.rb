module API
  class Forks < Grape::API
    resource :forks do
      # Create a fork
      #
      # Parameters:
      #   project_id (required) - The ID of a project
      #   project_token (requires) - Project token
      #   user_token(required) - User private token
      #   data (required) - GitLab push data
      #
      #
      # Example Request:
      #   POST /forks
      post do
        required_attributes! [:project_id, :data, :project_token, :user_token]
        project = Project.find_by!(gitlab_id: params[:project_id])
        authenticate_project_token!(project)

        user_session = UserSession.new
        user = user_session.authenticate_by_token(private_token: params[:user_token], url: GitlabCi.config.gitlab_server.url)

        fork = CreateProjectService.new.execute(
          user,
          params[:data],
          RoutesHelper.project_url(":project_id"),
          project
        )

        if fork
          present fork, with: Entities::Project
        else
          not_found!
        end
      end
    end
  end
end
