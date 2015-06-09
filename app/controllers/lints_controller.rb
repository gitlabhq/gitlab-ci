class LintsController < ApplicationController
  def show
  end

  def create
    if params[:content].blank?
      @status = false
      @error = "Please provide content of your file"
    else
      @config_processor = GitlabCiYamlProcessor.new params[:content]
      @status = true
    end
  rescue Psych::SyntaxError => e
    @error = e.message
    @status = false
  rescue Exception => e
    @error = "Undefined error"
    @status = false
  end
end