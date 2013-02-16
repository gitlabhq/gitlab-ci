class ApplicationController < ActionController::Base
  protect_from_forgery

  rescue_from Grit::InvalidGitRepositoryError do |exception|
    @error = "Project path is not a git repository"
    render "errors/show", status: 500
  end

  def authenticate_token!
    unless project.valid_token?(params[:token])
      return head(403)
    end
  end
end
