class RunnersController < ApplicationController
  before_filter :authenticate_user!
  before_filter :project
  before_filter :set_runner, only: [:edit, :update, :destroy]
  before_filter :authorize_access_project!

  layout 'project'

  def index
    @runners = @project.runners.order('id DESC').page(params[:page]).per(20)
  end

  def edit
  end

  def update
    runner_params = params[:runner]
    runner_params.delete(:token)

    if @runner.update_attributes(runner_params)
      redirect_to edit_project_runner_path(@project, @runner), notice: 'Runner was successfully updated.'
    else
      redirect_to edit_project_runner_path(@project, @runner), alert: 'Runner was not updated.'
    end
  end

  def destroy
    if @runner.only_for?(@project)
      @runner.destroy
    end

    redirect_to project_runners_path(@project)
  end

  protected

  def project
    @project = Project.find(params[:project_id])
  end

  def set_runner
    @runner ||= @project.runners.find(params[:id])
  end
end
