class Admin::BuildsController < Admin::ApplicationController
  def index
    @builds = Build.order('created_at DESC').page(params[:page]).per(30)
  end
end
