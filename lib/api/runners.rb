module API
  # Runners API
  class Runners < Grape::API
    resource :runners do
      before { authenticate_runners! }

      # Register a new runner
      #
      # Parameters:
      #   token (required) - The unique token of runner
      #   public_key (required) - Deploy key used to get projects
      #
      # Example Request:
      #   POST /runners/register
      post "register" do
        required_attributes! [:token, :public_key]

        runner = Runner.create(public_key: params[:public_key])

        if runner.id
          present runner, with: Entities::Runner
        else
          not_found!
        end
      end
    end
  end
end
