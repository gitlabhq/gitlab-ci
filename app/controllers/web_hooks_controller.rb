class WebHooksController < ApplicationController
  before_filter :authenticate_user!
  before_filter :project
  before_filter :authorize_access_project!

  layout 'project'

  def index
    @web_hooks = @project.web_hooks
    @web_hook = WebHook.new
  end

  def create
    @web_hook = @project.web_hooks.new(params[:web_hook])
    @web_hook.save

    if @web_hook.valid?
      redirect_to project_web_hooks_path(@project)
    else
      @web_hooks = @project.web_hooks.select(&:persisted?)
      render :index
    end
  end

  def test
    TestHookService.new.execute(hook, current_user)

    redirect_to :back
  end

  def destroy
    hook.destroy

    redirect_to project_web_hooks_path(@project)
  end

  private

  def hook
    @web_hook ||= @project.web_hooks.find(params[:id])
  end

  def project
    @project = Project.find(params[:project_id])
  end
end
