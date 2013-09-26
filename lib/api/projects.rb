module API
  # Projects API
  class Projects < Grape::API
    before { authenticate! }

    resource :projects do
      # Retrieve info for a project
      #
      # Parameters:
      #   id (required) - The ID of a project
      # Example Request:
      #   GET /projects/:id
      get ":id" do
        project = Project.find(params[:id])
        present project, with: Entities::Project
      end

      post do
        required_attributes! [:name, :gitlab_id, :gitlab_url, :ssh_url_to_repo]

        # TODO: Check if this has automatic filtering of attributes
        # via the Grape API

        filtered_params = {
          :name            => params[:name],
          :gitlab_id       => params[:gitlab_id],
          :gitlab_url      => params[:gitlab_url],
          :scripts         => params[:scripts] || 'ls -al',
          :default_ref     => params[:default_ref] || 'master',
          :ssh_url_to_repo => params[:ssh_url_to_repo]
        }

        project = Project.new(filtered_params)

        if project.save
          present project, :with => Entities::Project
        else
          errors = project.errors.full_messages.join(", ")
          render_api_error!(errors, 400)
        end
      end
    end
  end
end
