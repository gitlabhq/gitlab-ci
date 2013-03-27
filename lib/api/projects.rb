module GitlabCi
  # Projects API
  class Projects < Grape::API
    before { authenticate! }

    resource :projects do
      get do
        @projects = paginate Project.order("id DESC")
        present @projects, with: Entities::Project
      end

      get ":id" do
        present user_project, with: Entities::Project
      end

      post do
        required_attributes! [:name, :path, :scripts, :timeout, :default_ref]
        attrs = attributes_for_keys [:name,
                                    :path,
                                    :scripts,
                                    :timeout,
                                    :default_ref,
                                    :gitlab_url]
        @project = Project.new(attrs)
        @project.save
        if @project.saved?
          present @project, with: Entities::Project
        else
          not_found!
        end
      end

      delete ":id" do
        project = user_project
        project.destroy
      end
    end    
  end
end
