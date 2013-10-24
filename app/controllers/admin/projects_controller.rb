class Admin::ProjectsController < Admin::ApplicationController
  def index
    @projects = Project.page(params[:page]).per(30)
  end

  def show
    project
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
