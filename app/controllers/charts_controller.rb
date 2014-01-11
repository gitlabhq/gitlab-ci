class ChartsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :project
  before_filter :authorize_access_project!

  layout 'project'

  def index
  end

  def show
    case @chart
      when 'builds' then builds
      when 'build_times' then build_times
    end
  end

  def builds
    @charts = {}
    @charts[:week] = Charts::WeekChart.new(@project)
    @charts[:month] = Charts::MonthChart.new(@project)
    @charts[:year] = Charts::YearChart.new(@project)

    render :partial => 'charts/builds'
  end

  def build_times
    @charts = { :build_times => Charts::BuildTime.new(@project) }
    render :partial => 'charts/build_times'
  end

  protected

  def project
    @project = Project.find(params[:project_id])
    @chart = params[:id] || 'builds'
  end

end
