class BuildsController < ApplicationController
  before_filter :authenticate_user!, except: [:show]
  before_filter :project

  def show
    @build = @project.builds.find(params[:id])
  end

  protected

  def project
    @project = Project.find(params[:project_id])
  end
end
