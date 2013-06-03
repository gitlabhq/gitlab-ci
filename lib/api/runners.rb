module API
  # Issues API
  class Runners < Grape::API
    resource :runners do
      before { authenticate_runners!}

      # Register a build by runner
      #
      # Parameters:
      #   token (required) - The uniq token of runner
      #
      # Example Request:
      #   POST /builds/register
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
