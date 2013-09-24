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
        project = Project.where(id: params[:id])
        present project, with: Entities::Project
      end
    end
  end
end
