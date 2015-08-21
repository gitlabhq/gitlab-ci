class TriggersController < ApplicationController
  before_filter :authenticate_user!
  before_filter :project
  before_filter :authorize_access_project!
  before_filter :authorize_manage_project!

  layout 'project'

  def index
    @triggers = @project.triggers
    @trigger = Trigger.new
  end

  def create
    @trigger = @project.triggers.new
    @trigger.save

    if @trigger.valid?
      redirect_to project_triggers_path(@project)
    else
      @triggers = @project.triggers.select(&:persisted?)
      render :index
    end
  end

  def destroy
    trigger.destroy

    redirect_to project_triggers_path(@project)
  end

  private

  def trigger
    @trigger ||= @project.triggers.find(params[:id])
  end

  def project
    @project = Project.find(params[:project_id])
  end
end
