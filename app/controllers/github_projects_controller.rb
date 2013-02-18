class GithubProjectsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :only_github_users!

  def new
  end

  def create
    @project = GithubProject.build_for_repo(current_user, params[:github_repo])
    @project.save_with_github_repo!
    head :ok
  end

  def index
    @repositories = GithubRepo.all(current_user)
  end

  def regenerate
    @project = Project.find(params[:id])
    @project.generate_ssh_keys.save_with_github_repo!
    head :ok
  end

  private
    def only_github_users!
      unless current_user.github?
        redirect_to new_project_path
      end
    end
end
