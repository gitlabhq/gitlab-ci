class EventsController < ApplicationController
  EVENTS_PER_PAGE = 1

  before_filter :authenticate_user!
  before_filter :project
  before_filter :authorize_manage_project!

  layout 'project'

  def index
    @events = project.events.order("created_at DESC").page(params[:page]).per(EVENTS_PER_PAGE)
  end

  private

  def project
    @project ||= Project.find(params[:project_id])
  end
end
