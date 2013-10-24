module API
  # Builds API
  class Builds < Grape::API
    resource :builds do
      before { authenticate_runner! }

      # Runs oldest pending build by runner
      #
      # Parameters:
      #   token (required) - The uniq token of runner
      #
      # Example Request:
      #   POST /builds/register
      post "register" do
        required_attributes! [:token]

        ActiveRecord::Base.transaction do
          builds = Build.scoped
          builds = builds.where(project_id: current_runner.projects) unless current_runner.shared?
          build =  builds.first_pending

          not_found! and return unless build

          build.runner_id = current_runner.id
          build.save!
          build.run!
          present build, with: Entities::Build
        end
      end

      # Update an existing build
      #
      # Parameters:
      #   id (required) - The ID of a project
      #   state (optional) - The state of a build
      #   trace (optional) - The trace of a build
      # Example Request:
      #   PUT /builds/:id
      put ":id" do
        build = Build.where(runner_id: current_runner.id).running.find(params[:id])
        build.update_attributes(trace: params[:trace])

        case params[:state].to_s
        when 'success'
          build.success
        when 'failed'
          build.drop
        end
      end
    end
  end
end
