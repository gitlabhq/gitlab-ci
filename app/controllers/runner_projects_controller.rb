class RunnerProjectsController < ApplicationController
  before_filter :authenticate_user!
  layout 'project'

  def index
    @runner_projects = project.runner_projects.all
    @runner_project = project.runner_projects.new
  end

  def create
    @runner = Runner.find(params[:runner_project][:runner_id])

    if @runner.assign_to(project, current_user)
      redirect_to project_runner_projects_path
    else
      redirect_to project_runner_projects_path, alert: 'Failed adding runner deploy key to GitLab project'
    end
  end

  def destroy
    RunnerProject.find(params[:id]).destroy

    redirect_to project_runner_projects_path
  end

  private

  def project
    @project ||= Project.find(params[:project_id])
  end
end
