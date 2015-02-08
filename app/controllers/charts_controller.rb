class ChartsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :project
  before_filter :authorize_access_project!
  before_filter :authorize_manage_project!

  layout 'project'

  def show
    @charts = {}
    @charts[:week] = Charts::WeekChart.new(@project)
    @charts[:month] = Charts::MonthChart.new(@project)
    @charts[:year] = Charts::YearChart.new(@project)
    @charts[:build_times] = Charts::BuildTime.new(@project)
  end

  protected

  def project
    @project = Project.find(params[:project_id])
  end
end
