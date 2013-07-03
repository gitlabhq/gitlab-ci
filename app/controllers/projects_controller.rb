class ProjectsController < ApplicationController
  before_filter :authenticate_user!, except: [:build, :status, :index, :show]
  before_filter :project, only: [:build, :details, :show, :status, :edit, :update, :destroy, :stats]
  before_filter :authenticate_token!, only: [:build]
  before_filter :no_cache, only: [:status]

  layout 'project', except: [:index, :gitlab]

  def index
    @projects = Project.order('name ASC')
    @projects = @projects.public unless current_user
    @projects  = @projects.page(params[:page]).per(20)
  end

  def show
    unless @project.public || current_user
      authenticate_user! and return
    end

    @ref = params[:ref]


    @builds = @project.builds
    @builds = @builds.where(ref: @ref) if @ref
    @builds = @builds.order('id DESC').page(params[:page]).per(20)
  end

  def details
  end

  def create
    project = YAML.load(params[:project])

    params = {
      name: project.name_with_namespace,
      gitlab_id: project.id,
      gitlab_url: project.web_url,
      scripts: 'ls -la',
      default_ref: project.default_branch || 'master',
      ssh_url_to_repo: project.ssh_url_to_repo
    }

    @project = Project.new(params)

    if @project.save
      redirect_to project_path(@project, show_guide: true), notice: 'Project was successfully created.'
    else
      redirect_to :back, alert: 'Cannot save project'
    end
  end

  def edit
  end

  def update
    if project.update_attributes(params[:project])
      redirect_to project, notice: 'Project was successfully updated.'
    else
      render action: "edit"
    end
  end

  def destroy
    project.destroy

    redirect_to projects_url
  end

  def build
   # Ignore remove branch push
   return head(200) if params[:after] =~ /^00000000/

   # Support payload (like github) push
   build_params = if params[:payload]
                    HashWithIndifferentAccess.new(JSON.parse(params[:payload]))
                  else
                    params
                  end.dup

   @build = @project.register_build(build_params)

   if @build
     head 200
   else
     head 500
   end
  rescue
    head 500
  end

  # Project status badge
  # Image with build status for sha or ref
  def status
    image_name = if params[:sha]
                   @project.sha_status_image(params[:sha])
                 elsif params[:ref]
                   @project.status_image(params[:ref])
                 else
                   'unknown.png'
                 end

    send_file Rails.root.join('public', image_name), filename: image_name, disposition: 'inline'
  end

  def stats

  end

  def gitlab
    @projects = Project.from_gitlab(current_user)
  rescue
    @error = 'Failed to fetch GitLab projects'
  end

  protected

  def project
    @project ||= Project.find(params[:id])
  end

  def no_cache
    response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
  end
end
