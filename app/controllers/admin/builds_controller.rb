class Admin::BuildsController < Admin::ApplicationController
  before_filter :authenticate_user!
  before_filter :statistics, except: [:cancel]

  layout 'admin_builds', except: []

  def index
    @builds = Build.order('created_at DESC').page(params[:page]).per(30)
  end

  def statistics
    @total_count = Build.all.count
    @pending_count = Build.pending.count
    @running_count = Build.running.count
    @building_count = @pending_count + @running_count
    @finished_count = Build.success.count + Build.failed.count
  end

  def building
    @builds = Build.order('created_at ASC')
    @builds = @builds.where(status: [:pending, :running])
    @builds = @builds.page(params[:page]).per(30)
  end

  def finished
    @builds = Build.order('created_at DESC')
    @builds = @builds.where(status: [:success, :failed])
    @builds = @builds.page(params[:page]).per(30)
  end

  def charts
    @charts = {}
    @charts[:build_times] = Charts::GlobalBuildTime.new()
    @charts[:wait_times] = Charts::GlobalWaitTime.new()
    @charts[:week] = Charts::WeekChart.new(Build.all)
    @charts[:month] = Charts::MonthChart.new(Build.all)
    @charts[:year] = Charts::YearChart.new(Build.all)
    @success = Build.success
    @failed = Build.failed
    @uniq_sha = Build.uniq_sha
  end

  def cancel
    Build.all.where(status: [:pending, :running]).each do |build|
      build.cancel
    end

    redirect_to :back
  end
end
