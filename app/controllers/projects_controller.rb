require 'runner'

class ProjectsController < ApplicationController
  before_filter :authenticate_user!, except: [:build, :status]
  before_filter :project, only: [:build, :details, :show, :status, :edit, :update, :destroy]
  before_filter :authenticate_token!, only: [:build]

  def index
    @projects = Project.order('id DESC').paginate(page: params[:page], per_page: 20)
  end

  def show
    @ref = params[:ref]

    @builds = @project.builds
    @builds = @builds.where(ref: @ref) if @ref
    @builds = @builds.latest_sha.order('id DESC').paginate(page: params[:page], per_page: 20)
  end

  def details
  end

  def new
    @project = Project.new
  end

  def edit
  end

  def create
    @project = Project.new(params[:project])

    if @project.save
      redirect_to @project, notice: 'Project was successfully created.'
    else
      render action: "new"
    end
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

  def run
    @project = Project.find(params[:id])
    @build = @project.register_build(ref: params[:ref])

    if @build and @build.id
      Resque.enqueue(Runner, @build.id)
      redirect_to project_build_path(@project, @build)
    else
      redirect_to project_path(@project), notice: 'Branch is not defined for this project'
    end
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
     Resque.enqueue(Runner, @build.id) unless @build.ci_skip?
     head 200
   else
     head 500
   end
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

  protected

  def project
    @project ||= Project.find(params[:id])
  end
end
