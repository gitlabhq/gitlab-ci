class BuildsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :project

  def show
    @builds = @project.builds.where(sha: params[:id]).order('id DESC')

    @build = if params[:bid]
               @builds.where(id: params[:bid])
             else
               @builds
             end.limit(1).first


    @builds = @builds.paginate(:page => params[:page], :per_page => 20)
  end

  protected

  def project
    @project = Project.find(params[:project_id])
  end
end
