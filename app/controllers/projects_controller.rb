require 'runner'

class ProjectsController < ApplicationController
  before_filter :authenticate_user!, except: [:index]

  def index
    @projects = Project.all
  end

  def show
    @project = Project.find(params[:id])
    @builds = @project.builds.order('id DESC').paginate(:page => params[:page], :per_page => 20)
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
    @project = Project.find(params[:id])
    @build = @project.register_build

    Resque.enqueue(Runner, @build.id)

    redirect_to project_build_path(@project, @build)
  end
end
