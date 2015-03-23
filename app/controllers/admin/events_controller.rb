class Admin::EventsController < Admin::ApplicationController
  EVENTS_PER_PAGE = 50

  def index
    @events = Event.admin.order('created_at DESC').page(params[:page]).per(EVENTS_PER_PAGE)
  end
end