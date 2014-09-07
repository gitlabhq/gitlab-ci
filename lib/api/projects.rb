module API
  # Projects API
  class Projects < Grape::API
    before { authenticate! }

    resource :projects do
      # Retrieve all Gitlab CI projects that the user has access to
      #
      # Example Request:
      #   GET /projects
      get do
        gitlab_projects = Project.from_gitlab(
          current_user, params[:page], params[:per_page], :authorized
        )
        ids = gitlab_projects.map { |project| project.id }

        projects = Project.where("gitlab_id IN (?)", ids).load
        present projects, with: Entities::Project
      end

      # Retrieve all Gitlab CI projects that the user owns
      #
      # Example Request:
      #   GET /projects/owned
      get "owned" do
        gitlab_projects = Project.from_gitlab(
          current_user, params[:page], params[:per_page], :owned
        )
        ids = gitlab_projects.map { |project| project.id }

        projects = Project.where("gitlab_id IN (?)", ids).load
        present projects, with: Entities::Project
      end

      # Retrieve info for a Gitlab CI project
      #
      # Parameters:
      #   id (required) - The ID of a project
      # Example Request:
      #   GET /projects/:id
      get ":id" do
        project = Project.find(params[:id])

        if current_user.can_access_project?(project.gitlab_id)
          present project, with: Entities::Project
        else
          unauthorized!
        end
      end

      # Create Gitlab CI project using Gitlab project info
      #
      # Parameters:
      #   name (required)            - The name of the project
      #   gitlab_id (required)       - The gitlab id of the project
      #   gitlab_url (required)      - The gitlab web url to the project
      #   ssh_url_to_repo (required) - The gitlab ssh url to the repo
      #   scripts                    - The shell script provided for a runner to run
      #   default_ref                - The branch to run against (defaults to `master`)
      # Example Request:
      #   POST /projects
      post do
        required_attributes! [:name, :gitlab_id, :gitlab_url, :ssh_url_to_repo]

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

      # Update a Gitlab CI project
      #
      # Parameters:
      #   id (required)   - The ID of a project
      #   name            - The name of the project
      #   gitlab_id       - The gitlab id of the project
      #   gitlab_url      - The gitlab web url to the project
      #   ssh_url_to_repo - The gitlab ssh url to the repo
      #   scripts         - The shell script provided for a runner to run
      #   default_ref     - The branch to run against (defaults to `master`)
      # Example Request:
      #   PUT /projects/:id
      put ":id" do
        project = Project.find(params[:id])

        if project.present? && current_user.can_access_project?(project.gitlab_id)
          attrs = attributes_for_keys [:name, :gitlab_id, :gitlab_url, :scripts, :default_ref, :ssh_url_to_repo]

          if project.update_attributes(attrs)
            present project, :with => Entities::Project
          else
            errors = project.errors.full_messages.join(", ")
            render_api_error!(errors, 400)
          end
        else
          not_found!
        end
      end

      # Remove a Gitlab CI project
      #
      # Parameters:
      #   id (required) - The ID of a project
      # Example Request:
      #   DELETE /projects/:id
      delete ":id" do
        project = Project.find(params[:id])

        if project.present? && current_user.can_access_project?(project.gitlab_id)
          project.destroy
        else
          not_found!
        end
      end

      # Link a Gitlab CI project to a runner
      #
      # Parameters:
      #   id (required) - The ID of a CI project
      #   runner_id (required) - The ID of a runner
      # Example Request:
      #   POST /projects/:id/runners/:runner_id
      post ":id/runners/:runner_id" do
        project = Project.find_by_id(params[:id])
        runner  = Runner.find_by_id(params[:runner_id])

        not_found! if project.blank? or runner.blank?

        unauthorized! unless current_user.can_access_project?(project.gitlab_id)

        options = {
          :project_id => project.id,
          :runner_id  => runner.id
        }

        runner_project = RunnerProject.new(options)

        if runner_project.save
          present runner_project, :with => Entities::RunnerProject
        else
          errors = project.errors.full_messages.join(", ")
          render_api_error!(errors, 400)
        end
      end

      # Remove a Gitlab CI project from a runner
      #
      # Parameters:
      #   id (required) - The ID of a CI project
      #   runner_id (required) - The ID of a runner
      # Example Request:
      #   DELETE /projects/:id/runners/:runner_id
      delete ":id/runners/:runner_id" do
        project = Project.find_by_id(params[:id])
        runner  = Runner.find_by_id(params[:runner_id])

        not_found! if project.blank? or runner.blank?
        unauthorized! unless current_user.can_access_project?(project.gitlab_id)

        options = {
          :project_id => project.id,
          :runner_id  => runner.id
        }

        runner_project = RunnerProject.where(options).first

        if runner_project.present?
          runner_project.destroy
        else
          not_found!
        end
      end
    end
  end
end
