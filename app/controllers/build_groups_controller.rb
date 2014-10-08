class BuildGroupsController < ApplicationController
  before_filter :authenticate_user!, except: [:status]
  before_filter :project
  before_filter :authorize_access_project!, except: [:status]
  before_filter :build_group, except: [:status, :show]

  def show
    if params[:id] =~ /\A\d+\Z/
      @build_group = build_group
    else
      # try to find build by sha
      build_group = build_group_by_sha

      if build
        # Redirect from sha to build with id
        redirect_to project_build_group_path(build_group.project, build_group)
        return
      end
    end

    raise ActiveRecord::RecordNotFound unless @build_group

    @builds = @build_group.builds
  end

  def cancel
    build_group.cancel

    redirect_to project_build_group_path(@project, build_group)
  end

  def retry
    new_build_group = CreateBuildService.new.execute(project, build_group.push_data)
    unless new_build_group
      redirect_to project_build_group_path(project, build_group), alert: 'Cannot retry build'
      return
    end

    redirect_to project_build_group_path(project, new_build_group)
  end

  def status
    @build_group = build_group_by_sha

    render json: @build_group.to_json(only: [:status, :id, :sha])
  end

  protected

  def project
    @project = Project.find(params[:project_id])
  end

  def build_group
    @build_group ||= project.build_groups.find_by(id: params[:id])
  end

  def build_group_by_sha
    project.build_groups.where(sha: params[:id]).last
  end
end