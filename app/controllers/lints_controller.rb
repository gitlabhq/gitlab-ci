class LintsController < ApplicationController
  before_filter :authenticate_user!

  def show
  end

  def create
    if params[:content].blank?
      @status = false
      @error = "Please provide content of .gitlab-ci.yml"
    else
      @config_processor = GitlabCiYamlProcessor.new params[:content]
      @builds = @config_processor.builds
      @deploy_builds = @config_processor.deploy_builds
      @status = true
    end
  rescue GitlabCiYamlProcessor::ValidationError => e
    @error = e.message
    @status = false
  rescue Exception => e
    @error = "Undefined error"
    @status = false
  end
end
