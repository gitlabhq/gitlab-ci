class EventsController < ApplicationController
  EVENTS_PER_PAGE = 50

  before_filter :authenticate_user!
  before_filter :project
  before_filter :authorize_manage_project!

  layout 'project'

  def index
    page = (params[:page] || 1).to_i
    @events = project.events.order("created_at DESC").page(page).per(EVENTS_PER_PAGE)
  end

  private

  def project
    @project ||= Project.find(params[:project_id])
  end
end
