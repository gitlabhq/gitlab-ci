module API
  # Builds API
  class Builds < Grape::API
    resource :builds do
      # Runs oldest pending build by runner - Runners only
      #
      # Parameters:
      #   token (required) - The uniq token of runner
      #
      # Example Request:
      #   POST /builds/register
      post "register" do
        authenticate_runner!
        required_attributes! [:token]
        build = RegisterBuildService.new.execute(current_runner)

        if build
          present build, with: Entities::Build
        else
          not_found!
        end
      end

      # Update an existing build - Runners only
      #
      # Parameters:
      #   id (required) - The ID of a project
      #   state (optional) - The state of a build
      #   trace (optional) - The trace of a build
      # Example Request:
      #   PUT /builds/:id
      put ":id" do
        authenticate_runner!
        build = Build.where(runner_id: current_runner.id).running.find(params[:id])
        build.update_attributes(trace: params[:trace]) if params[:trace]

        case params[:state].to_s
        when 'success'
          build.success
        when 'failed'
          build.drop
        end
      end

      # TODO: Remove it after 5.2 release
      #
      # THIS API IS DEPRECATED.
      # Now builds are created by commit. In order to test specific commit you
      # need to create Commit entity via Commit API
      #
      # Create a build
      #
      # Parameters:
      #   project_id (required) - The ID of a project
      #   project_token (requires) - Project token
      #   data (required) - GitLab push data
      #
      #   Sample GitLab push data:
      #   {
      #     "before": "95790bf891e76fee5e1747ab589903a6a1f80f22",
      #     "after": "da1560886d4f094c3e6c9ef40349f7d38b5d27d7",
      #     "ref": "refs/heads/master",
      #     "commits": [
      #       {
      #         "id": "b6568db1bc1dcd7f8b4d5a946b0b91f9dacd7327",
      #         "message": "Update Catalan translation to e38cb41.",
      #         "timestamp": "2011-12-12T14:27:31+02:00",
      #         "url": "http://localhost/diaspora/commits/b6568db1bc1dcd7f8b4d5a946b0b91f9dacd7327",
      #         "author": {
      #           "name": "Jordi Mallach",
      #           "email": "jordi@softcatala.org",
      #         }
      #       }, .... more commits
      #     ]
      #   }
      #
      # Example Request:
      #   POST /builds
      post do
        required_attributes! [:project_id, :data, :project_token]
        project = Project.find(params[:project_id])
        authenticate_project_token!(project)
        commit = CreateCommitService.new.execute(project, params[:data])

        # Temporary solution to keep api compatibility
        build = commit.builds.first

        if build.persisted?
          present build, with: Entities::Build
        else
          errors = build.errors.full_messages.join(", ")
          render_api_error!(errors, 400)
        end
      end
    end
  end
end
