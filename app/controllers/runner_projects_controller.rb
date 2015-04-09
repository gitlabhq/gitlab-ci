class RunnerProjectsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :project
  before_filter :authorize_manage_project!

  layout 'project'

  def create
    @runner = Runner.find(params[:runner_project][:runner_id])

    return head(403) unless current_user.authorized_runners.include?(@runner)

    if @runner.assign_to(project, current_user)
      redirect_to project_runners_path(project)
    else
      redirect_to project_runners_path(project), alert: 'Failed adding runner to project'
    end
  end

  def destroy
    runner_project = project.runner_projects.find(params[:id])
    runner_project.destroy

    redirect_to project_runners_path(project)
  end

  private

  def project
    @project ||= Project.find(params[:project_id])
  end
end
