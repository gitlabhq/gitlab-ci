class ApplicationController < ActionController::Base
  protect_from_forgery

  rescue_from Grit::InvalidGitRepositoryError do |exception|
    @error = "Project path is not a git repository"
    render "errors/show", status: 500
  end
end
