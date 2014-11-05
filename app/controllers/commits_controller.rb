class CommitsController < ApplicationController
  before_filter :authenticate_user!, except: [:status]
  before_filter :project
  before_filter :commit
  before_filter :authorize_access_project!, except: [:status]

  def show
    @builds = @commit.builds
  end

  def status
    render json: @commit.to_json(only: [:id, :sha], methods: [:status, :coverage])
  end

  private

  def project
    @project ||= Project.find(params[:project_id])
  end

  def commit
    @commit ||= project.commits.find_by(sha: params[:id])
  end
end
