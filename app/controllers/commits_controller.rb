class CommitsController < ApplicationController
  before_filter :authenticate_user!, except: [:status]
  before_filter :project
  before_filter :authorize_access_project!, except: [:status]

  def show
    @commit = project.commits.find_by_sha_and_ref!(params[:sha], params[:ref])
    @builds = @commit.builds
  end

  def status
    @commit = project.commits.find_by(sha: params[:id])
    render json: @commit.to_json(only: [:id, :sha], methods: [:status, :coverage])
  end

  private

  def project
    @project ||= Project.find(params[:project_id])
  end
end
