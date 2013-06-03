class ApplicationController < ActionController::Base
  protect_from_forgery

  helper_method :current_user

  private

  def authenticate_token!
    unless project.valid_token?(params[:token])
      return head(403)
    end
  end

  def current_user
    @current_user ||= session[:current_user]
  end

  def sign_in(user)
    session[:current_user] = OpenStruct.new(user)
  end

  def sign_out
    @current_user = session[:current_user] = nil
  end
end
