class RunnersController < ApplicationController
  before_filter :authenticate_user!
  before_filter :project
  before_filter :authorize_access_project!

  layout 'project'

  def index
    @runners = @project.runners.page(params[:page]).per(20)
  end

  def destroy
    @runner = @project.runners.find(params[:id])

    if @runner.only_for?(@project)
      @runner.destroy
    end

    redirect_to project_runners_path(@project)
  end

  protected

  def project
    @project = Project.find(params[:project_id])
  end
end
