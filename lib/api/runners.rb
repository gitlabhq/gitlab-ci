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
        authenticate_runners!
        required_attributes! [:token]

        runner = Runner.create

        if runner.id
          present runner, with: Entities::Runner
        else
          not_found!
        end
      end
    end
  end
end
