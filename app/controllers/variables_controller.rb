class VariablesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :project
  before_filter :authorize_access_project!
  before_filter :authorize_manage_project!

  layout 'project'

  def show
  end

  def update
    if project.update_attributes(project_params)
      EventService.new.change_project_settings(current_user, project)

      redirect_to :back, notice: 'Variables was successfully updated.'
    else
      render action: 'show'
    end
  end

  private

  def project
    @project ||= Project.find(params[:project_id])
  end

  def project_params
    params.require(:project).permit({ variables_attributes: [:id, :key, :value, :_destroy] })
  end
end
