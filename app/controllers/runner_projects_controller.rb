class RunnerProjectsController < ApplicationController
  before_filter :authenticate_user!

  def index
    @runner_projects = project.runner_projects.all
    @runner_project = project.runner_projects.new
  end

  def create
    ActiveRecord::Base.transaction do
      @runner_project = project.runner_projects.create!(params[:runner_project])

      runner = @runner_project.runner

      opts = {
        key: runner.public_key,
        title: "gitlab-ci-runner-#{runner.id}",
        private_token: current_user.private_token
      }

      result = Network.new.add_deploy_key(current_user.url, project.gitlab_id, opts)
      raise "Can't add deploy key" unless result
    end

  ensure
    redirect_to project_runner_projects_path
  end

  def destroy
    RunnerProject.find(params[:id]).destroy

    redirect_to project_runner_projects_path
  end

  private

  def project
    @project ||= Project.find(params[:project_id])
  end
end
