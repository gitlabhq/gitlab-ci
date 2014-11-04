class CommitsController < ApplicationController
  before_filter :authenticate_user!, except: [:status]
  before_filter :project
  before_filter :authorize_access_project!, except: [:status]

  def show
    @commit = project.commits.find_by(sha: params[:id])
    @builds = @commit.builds
  end

  private

  def project
    @project = Project.find(params[:project_id])
  end
end
