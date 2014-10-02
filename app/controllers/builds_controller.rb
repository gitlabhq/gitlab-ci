class BuildsController < ApplicationController
  before_filter :authenticate_user!, except: [:status]
  before_filter :project
  before_filter :authorize_access_project!, except: [:status]
  before_filter :build, except: [:status, :show]

  def show
    if params[:id] =~ /\A\d+\Z/
      @build = build
    else
      # try to find build by sha
      build = build_by_sha

      if build
        # Redirect from sha to build with id
        redirect_to project_build_path(build.project, build)
        return
      end
    end

    raise ActiveRecord::RecordNotFound unless @build

    @builds = project.builds.where(sha: @build.sha).order('id DESC')
    @builds = @builds.where("id not in (?)", @build.id).page(params[:page]).per(20)

    respond_to do |format|
      format.html
      format.json {
        render json: @build.to_json(methods: :trace_html)
      }
    end
  end

  def retry
    build = project.builds.create(
      sha: @build.sha,
      before_sha: @build.before_sha,
      push_data: @build.push_data,
      ref: @build.ref
    )

    redirect_to project_build_path(project, build)
  end

  def status
    @build = build_by_sha

    render json: @build.to_json(only: [:status, :id, :sha, :coverage])
  end

  def cancel
    @build.cancel

    redirect_to project_build_path(@project, @build)
  end

  protected

  def project
    @project = Project.find(params[:project_id])
  end

  def build
    @build ||= project.builds.find_by(id: params[:id])
  end

  def build_by_sha
    project.builds.where(sha: params[:id]).last
  end
end
