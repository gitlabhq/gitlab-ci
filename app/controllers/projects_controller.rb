class ProjectsController < ApplicationController
  PROJECTS_BATCH = 100

  before_filter :authenticate_user!, except: [:build, :badge, :index, :show]
  before_filter :authenticate_public_page!, only: :show
  before_filter :project, only: [:build, :integration, :show, :badge, :edit, :update, :destroy, :toggle_shared_runners]
  before_filter :authorize_access_project!, except: [:build, :gitlab, :badge, :index, :show, :new, :create]
  before_filter :authorize_manage_project!, only: [:edit, :integration, :update, :destroy, :toggle_shared_runners]
  before_filter :authenticate_token!, only: [:build]
  before_filter :no_cache, only: [:badge]
  protect_from_forgery except: :build

  layout 'project', except: [:index, :gitlab]

  def index
    @projects = Project.ordered_by_last_commit_date.public_only.page(params[:page]) unless current_user
  end

  def gitlab
    @limit, @offset = (params[:limit] || PROJECTS_BATCH).to_i, (params[:offset] || 0).to_i
    @page = @offset == 0 ? 1 : (@offset / @limit + 1)

    current_user.reset_cache if params[:reset_cache]

    @gl_projects = current_user.gitlab_projects(params[:search], @page, @limit)
    @projects = Project.where(gitlab_id: @gl_projects.map(&:id)).ordered_by_last_commit_date
    @total_count = @gl_projects.size
    @gl_projects.reject! { |gl_project| @projects.map(&:gitlab_id).include?(gl_project.id) }
    respond_to do |format|
      format.json do
        pager_json("projects/gitlab", @total_count)
      end
    end
  rescue Network::UnauthorizedError
    raise
  rescue
    @error = 'Failed to fetch GitLab projects'
  end

  def show
    @ref = params[:ref]

    @commits = @project.commits
    @commits = @commits.where(ref: @ref) if @ref
    @commits = @commits.order('id DESC').page(params[:page]).per(20)
  end

  def integration
  end

  def create
    project_data = OpenStruct.new(JSON.parse(params["project"]))

    unless current_user.can_manage_project?(project_data.id)
      return redirect_to root_path, alert: 'You have to have at least master role to enable CI for this project'
    end

    @project = CreateProjectService.new.execute(current_user, project_data, project_url(":project_id"))

    if @project.persisted?
      redirect_to project_path(@project, show_guide: true), notice: 'Project was successfully created.'
    else
      redirect_to :back, alert: 'Cannot save project'
    end
  end

  def edit
  end

  def update
    if project.update_attributes(project_params)
      EventService.new.change_project_settings(current_user, project)

      redirect_to :back, notice: 'Project was successfully updated.'
    else
      render action: "edit"
    end
  end

  def destroy
    project.destroy
    Network.new.disable_ci(project.gitlab_id, current_user.private_token)

    EventService.new.remove_project(current_user, project)

    redirect_to projects_url
  end

  def build
    @commit = CreateCommitService.new.execute(@project, params.dup)

    if @commit && @commit.valid?
      head 201
    else
      head 400
    end
  end

  # Project status badge
  # Image with build status for sha or ref
  def badge
    image = ImageForBuildService.new.execute(@project, params)

    send_file image.path, filename: image.name, disposition: 'inline', type:"image/svg+xml"
  end

  def toggle_shared_runners
    project.toggle!(:shared_runners_enabled)
    redirect_to :back
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

  def project_params
    params.require(:project).permit(:path, :timeout, :timeout_in_minutes, :default_ref, :always_build,
      :polling_interval, :public, :ssh_url_to_repo, :allow_git_fetch, :skip_refs, :email_recipients,
      :email_add_pusher, :email_only_broken_builds, :coverage_regex, :shared_runners_enabled, :token,
      { jobs_attributes: [:id, :name, :build_branches, :build_tags, :tag_list, :commands, :refs, :_destroy, :job_type] })
  end
end
