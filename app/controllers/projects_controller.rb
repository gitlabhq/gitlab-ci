require 'runner'

class ProjectsController < ApplicationController
  before_filter :authenticate_user!, except: [:build, :status, :index, :show]
  before_filter :project, only: [:build, :details, :show, :status, :edit, :update, :destroy, :stats]
  before_filter :authenticate_token!, only: [:build]
  before_filter :no_cache, only: [:status]

  def index
    @projects = Project.order('id DESC')
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
    @builds = @builds.latest_sha.order('id DESC').page(params[:page]).per(20)
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
      Runner.perform_async(@build.id) unless @build.ci_skip?
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
     Runner.perform_async(@build.id)
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

  def stats

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
