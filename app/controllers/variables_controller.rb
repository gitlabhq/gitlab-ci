class VariablesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :project
  before_filter :authorize_access_project!
  before_filter :authorize_manage_project!

  layout 'project'

  def index
  end

  private

  def project
    @project ||= Project.find(params[:project_id])
  end
end