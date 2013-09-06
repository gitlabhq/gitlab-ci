class ApplicationController < ActionController::Base
  protect_from_forgery

  helper_method :current_user
  before_filter :reset_cache

  private

  def current_user
    @current_user ||= session[:current_user]
  end

  def sign_in(user)
    session[:current_user] = user
  end

  def sign_out
    reset_session
  end

  def authenticate_user!
    unless current_user
      redirect_to new_user_sessions_path
      return
    end
  end

  def authenticate_token!
    unless project.valid_token?(params[:token])
      return head(403)
    end
  end

  def authorize_access_project!
    unless current_user.can_access_project?(@project.gitlab_id)
      return page_404
    end
  end

  def page_404
    render file: "#{Rails.root}/public/404.html", status: 404, layout: false
  end

  # Reset user cache every day for security purposes
  def reset_cache
    if current_user && current_user.sync_at < (Time.zone.now - 24.hours)
      current_user.reset_cache
    end
  end
end
