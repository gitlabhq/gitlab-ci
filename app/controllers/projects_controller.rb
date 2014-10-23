class ProjectsController < ApplicationController
  before_filter :authenticate_user!, except: [:build, :tag, :badge, :index, :show, :tags]
  before_filter :project, only: [:build, :tag, :integration, :show, :tags, :badge, :edit, :update, :destroy, :cancel]
  before_filter :authorize_access_project!, except: [:build, :tag, :gitlab, :badge, :index, :show, :tags, :new, :create]
  before_filter :authenticate_token!, only: [:build, :tag]
  before_filter :no_cache, only: [:badge]

  layout 'project', except: [:index, :gitlab]

  def index
    @projects = Project.public_only.page(params[:page]) unless current_user
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
        redirect_to(new_user_sessions_path(return_to: request.fullpath)) and return
      end

      unless current_user.can_access_project?(@project.gitlab_id)
        page_404 and return
      end
    end

    @ref = params[:ref]

    # @builds = @project.builds
    # @builds = @builds.where(ref: @ref) if @ref
    # @builds = @builds.order('id DESC').page(params[:page]).per(20)

    @build_groups = @project.build_groups
    @build_groups = @build_groups.where(ref: @ref) if @ref
    @build_groups = @build_groups.order('id DESC').page(params[:page]).per(20)
  end

  def tags
    unless @project.public
      unless current_user
        redirect_to(new_user_sessions_path(return_to: request.fullpath)) and return
      end

      unless current_user.can_access_project?(@project.gitlab_id)
        page_404 and return
      end
    end

    @build_groups = @project.build_groups.tags
    @build_groups = @build_groups.order('id DESC').page(params[:page]).per(20)
  end

  def integration
  end

  def create
    @project = CreateProjectService.new.execute(current_user, params[:project], project_url(":project_id"))

    if @project.persisted?
      redirect_to project_path(@project, show_guide: true), notice: 'Project was successfully created.'
    else
      redirect_to :back, alert: 'Cannot save project'
    end
  end

  def edit
  end

  def update
    begin
      Project.transaction do
        project.assign_attributes(params[:project])
        CreateProjectService.new.update(current_user, project, project_url(":project_id"))
      end
      redirect_to project, notice: 'Project was successfully updated.'
    rescue => e
      render action: "edit", alert: e.to_s
    end
  end

  def destroy
    CreateProjectService.new.destroy(current_user, project, project_url(":project_id"))

    redirect_to projects_url
  end

  def build
    @build = CreateBuildService.new.execute(@project, params.dup)

    if @build && @build.persisted?
      head 201
    else
      head 400
    end
  end

  def tag
    data = params.dup

    # check if reg is tag
    ref = data[:ref]
    unless ref and ref.include?('refs/tags/')
      head 400
      return
    end
    ref = ref.scan(/tags\/(.*)$/).flatten[0]

    gitlab_url = project.gitlab_url.split('/')[0..-3].join('/')

    # fill missing commits
    commits = Network.new.commits_for_ref(gitlab_url, project.gitlab_id, project.private_token, ref)
    unless commits
      head 400
      return
    end

    # convert all strings to symbols
    commits.map do |commit|
      commit.deep_symbolize_keys!
    end

    data[:after] = commits.first[:id] # use commit id from network
    data[:commits] = commits
    data[:total_commits_count] = commits.count

    # create builds
    @build = CreateBuildService.new.execute(@project, data)

    if @build && @build.persisted?
      head 201
    else
      head 400
    end
  end

  # Project status badge
  # Image with build status for sha or ref
  def badge
    image = ImageForBuildService.new.execute(@project, params)

    send_file image.path, filename: image.name, disposition: 'inline'
  end

  def cancel
    @project.builds.pending.each do |build|
      build.cancel
    end
    @project.builds.running.each do |build|
      build.cancel
    end
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
end
