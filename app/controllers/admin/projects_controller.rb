class Admin::ProjectsController < Admin::ApplicationController
  def index
    @projects = Project.ordered_by_last_commit_date.page(params[:page]).per(30)
  end

  def destroy
    project.destroy

    redirect_to projects_url
  end

  protected

  def project
    @project ||= Project.find(params[:id])
  end
end
