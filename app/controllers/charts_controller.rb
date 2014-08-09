class ChartsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :project
  before_filter :authorize_access_project!

  layout 'project'

  def show
    @charts = {}
    @charts[:week] = Charts::WeekChart.new(@project.builds)
    @charts[:month] = Charts::MonthChart.new(@project.builds)
    @charts[:year] = Charts::YearChart.new(@project.builds)
    @charts[:build_times] = Charts::BuildTime.new(@project.builds)
  end

  protected

  def project
    @project = Project.find(params[:project_id])
  end
end
