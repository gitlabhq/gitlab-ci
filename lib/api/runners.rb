module API
  # Runners API
  class Runners < Grape::API
    resource :runners do
      # Get list of all available runners
      #
      # Example Request:
      #   GET /runners
      get do
        authenticate!
        runners = Runner.all

        if runners.present?
          present runners, with: Entities::Runner
        else
          not_found!
        end
      end

      # Delete runner
      # Parameters:
      #   token (required) - The unique token of runner
      #
      # Example Request:
      #   GET /runners/delete
      delete "delete" do
        required_attributes! [:token]
        authenticate_runner!
        Runner.find_by_token(params[:token]).destroy
      end

      # Register a new runner
      #
      # Note: This is an "internal" API called when setting up
      # runners, so it is authenticated differently.
      #
      # Parameters:
      #   token (required) - The unique token of runner
      #
      # Example Request:
      #   POST /runners/register
      post "register" do
        required_attributes! [:token]

        runner =
          if params[:token] == GitlabCi::REGISTRATION_TOKEN
            # Create shared runner. Requires admin access
            Runner.create(
              description: params[:description],
              tag_list: params[:tag_list]
            )
          elsif project = Project.find_by(token: params[:token])
            # Create a specific runner for project.
            project.runners.create(
              description: params[:description],
              tag_list: params[:tag_list]
            )
          end

        return forbidden! unless runner

        if runner.id
          present runner, with: Entities::Runner
        else
          not_found!
        end
      end
    end
  end
end
