class ApplicationController < ActionController::Base
  protect_from_forgery

  def authenticate_token!
    unless project.valid_token?(params[:token])
      return head(403)
    end
  end
end
