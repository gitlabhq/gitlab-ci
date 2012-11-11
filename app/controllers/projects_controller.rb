require 'runner'

class ProjectsController < ApplicationController
  before_filter :authenticate_user!, except: [:index, :build, :status]

  def index
    @projects = Project.all
  end

  def show
    @project = Project.find(params[:id])
    @builds = @project.builds.latest_sha.order('id DESC').paginate(:page => params[:page], :per_page => 20)
  end

  def new
    @project = Project.new
  end

  def edit
    @project = Project.find(params[:id])
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
    @project = Project.find(params[:id])

    if @project.update_attributes(params[:project])
      redirect_to @project, notice: 'Project was successfully updated.'
    else
      render action: "edit"
    end
  end

  def destroy
    @project = Project.find(params[:id])
    @project.destroy

    redirect_to projects_url
  end

  def run
    #TODO remove or modify this functionality. Now it is broken
    @project = Project.find(params[:id])
    @build = @project.register_build

    Resque.enqueue(Runner, @build.id)

    redirect_to project_build_path(@project, @build)
  end

  def build
    @project = Project.find(params[:id])

    if @project.token && @project.token == params[:token]
      @build = @project.register_build(params)
      Resque.enqueue(Runner, @build.id)
      head 200
    else
      head 403
    end
  end

  def status
    @project = Project.find(params[:id])

    send_file Rails.root.join('public', @project.status_image), filename: 'success.png', disposition: 'inline'
  end
end
