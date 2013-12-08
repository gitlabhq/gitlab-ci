class ProjectsController < ApplicationController
  before_filter :authenticate_user!, except: [:build, :badge, :index, :show]
  before_filter :project, only: [:build, :integration, :show, :badge, :edit, :update, :destroy, :charts]
  before_filter :authorize_access_project!, except: [:build, :gitlab, :badge, :index, :show, :new, :create]
  before_filter :authenticate_token!, only: [:build]
  before_filter :no_cache, only: [:badge]

  layout 'project', except: [:index, :gitlab]

  def index
    @projects = Project.public.page(params[:page]) unless current_user
  end

  def gitlab
    current_user.reset_cache if params[:reset_cache]
    @page = (params[:page] || 1).to_i
    @per_page = 100
    @gl_projects = current_user.gitlab_projects(@page, @per_page)
    @projects = Project.where(gitlab_id: @gl_projects.map(&:id)).order('name ASC')
    @total_count = @gl_projects.size
    @gl_projects.reject! { |gl_project| @projects.map(&:gitlab_id).include?(gl_project.id) }
  rescue
    @error = 'Failed to fetch GitLab projects'
  end

  def show
    unless @project.public
      unless current_user
        redirect_to(new_user_sessions_path) and return
      end

      unless current_user.can_access_project?(@project.gitlab_id)
        page_404 and return
      end
    end

    @ref = params[:ref]

    @builds = @project.builds
    @builds = @builds.where(ref: @ref) if @ref
    @builds = @builds.order('id DESC').page(params[:page]).per(20)
  end

  def integration
  end

  def create
    @project = Project.parse(params[:project])

    Project.transaction do
      @project.save!

      opts = {
        token: @project.token,
        project_url: project_url(@project),
      }

      if Network.new.enable_ci(current_user.url, @project.gitlab_id, opts, current_user.private_token)
        true
      else
        raise ActiveRecord::Rollback
      end
    end

    if @project.persisted?
      redirect_to project_path(@project, show_guide: true), notice: 'Project was successfully created.'
    else
      redirect_to :back, alert: 'Cannot save project'
    end
  end

  def edit
  end

  def update
    if project.update_attributes(params[:project])
      redirect_to project, notice: 'Project was successfully updated.'
    else
      render action: "edit"
    end
  end

  def destroy
    project.destroy
    Network.new.disable_ci(current_user.url, project.gitlab_id, current_user.private_token)

    redirect_to projects_url
  end

  def build
   # Ignore remove branch push
   return head(200) if params[:after] =~ /^00000000/

   build_params = params.dup
   @build = @project.register_build(build_params)

   if @build
     head 200
   else
     head 500
   end
  rescue
    head 500
  end

  # Project status badge
  # Image with build status for sha or ref
  def badge
    image_name = if params[:sha]
                   @project.sha_status_image(params[:sha])
                 elsif params[:ref]
                   @project.status_image(params[:ref])
                 else
                   'unknown.png'
                 end

    send_file Rails.root.join('public', image_name), filename: image_name, disposition: 'inline'
  end

  def charts
    @charts = {}
    @charts[:week] = Charts::WeekChart.new(@project)
    @charts[:month] = Charts::MonthChart.new(@project)
    @charts[:year] = Charts::YearChart.new(@project)
  end

  protected

  def project
    @project ||= Project.find(params[:id])
  end

  def no_cache
    response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
  end
end
