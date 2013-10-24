class Admin::RunnerProjectsController < Admin::ApplicationController
  before_filter :authenticate_user!
  layout 'project'

  def index
    @runner_projects = project.runner_projects.all
    @runner_project = project.runner_projects.new
  end

  def create
    @runner = Runner.find(params[:runner_project][:runner_id])

    if @runner.assign_to(project, current_user)
      redirect_to admin_runner_path(@runner)
    else
      redirect_to admin_runner_path(@runner), alert: 'Failed adding runner to project'
    end
  end

  def destroy
    rp = RunnerProject.find(params[:id])
    runner = rp.runner
    rp.destroy

    redirect_to admin_runner_path(runner)
  end

  private

  def project
    @project ||= Project.find(params[:project_id])
  end
end
