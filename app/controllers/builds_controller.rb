class BuildsController < ApplicationController
  before_filter :authenticate_user!, except: [:status]
  before_filter :project
  before_filter :authorize_access_project!, except: [:status]
  before_filter :build, except: [:status, :show, :tag, :create]

  layout 'project', only: [:new, :create]

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
      format.text {
        render text: @build.trace
      }
      format.sh {
        render text: @build.commands
      }
    end
  end

  def new
    @build = Build.new
    @ref = @project.tracked_refs.first
    @ref_type = 'tags'
    @tag_name = '1.0'
    @tag_message = ''
    @alert = nil

    # Fill with last tag message
    last_tag = @project.build_groups.tags.last
    @tag_name = last_tag.ref if last_tag
    @tag_message = last_tag.ref_or_commit_message if last_tag
  end

  def create
    build = params[:build]
    @ref = build[:ref]
    @ref_type = build[:ref_type]
    @ref_message = nil
    @tag_name = build[:tag_name]
    @tag_message = build[:tag_message]
    @alert = nil

    case @ref_type
      when 'heads'
        commit = Network.new.commit_for_ref_or_sha(current_user.url, project.gitlab_id, current_user.private_token, @ref)
        unless commit
          @alert = 'Cannot create build. Invalid ref name.'
          render 'new'
          return
        end

        commit = commit.deep_symbolize_keys

      when 'tags'
        tag_opts = {
            tag_name: @tag_name,
            message: @tag_message,
            ref: @ref
        }

        begin
          created_tag = Network.new.create_tag(current_user.url, project.gitlab_id, current_user.private_token, tag_opts)
        rescue => e
         @alert = "Cannot create tagged build: #{e.to_s}"
         render 'new'
         return
        end

        created_tag = created_tag.deep_symbolize_keys
        commit = created_tag[:commit]
        @ref = @tag_name
        @ref_message = @tag_message

      else
        @alert = 'Invalid option selected'
        render 'new'
        return
    end

    after = commit[:id]
    before = commit[:parent_ids].first if commit[:parent_ids]
    before ||= '0000000'
    ref = "refs/#{@ref_type}/#{@ref}"

    data = {
        after: after,
        before: before,
        ref: ref,
        ref_message: @ref_message,
        commits: [
            commit
        ]
    }

    begin
      @build_group = CreateBuildService.new.execute(project, data)

      if @build_group
        redirect_to project_build_group_path(project, @build_group)
      else
        @alert = 'No build created.'
        render 'new'
      end
    rescue => e
      @alert = "Cannot create build: #{e.to_s}"
      render 'new'
    end
  end

  def retry
    build_group = project.build_groups.create(
        sha: @build.sha,
        before_sha: @build.before_sha,
        push_data: @build.push_data,
        ref: @build.ref,
        ref_type: @build.ref_type,
        ref_message: @build.ref_message,
    )

    build = project.builds.create(
      sha: @build.sha,
      before_sha: @build.before_sha,
      push_data: @build.push_data,
      ref: @build.ref,
      ref_type: @build.ref_type,
      ref_message: @build.ref_message,
      labels: @build.labels,
      build_method: @build.build_method,
      build_attributes: @build.build_attributes,
      matrix_attributes: @build.matrix_attributes,
      build_group_id: build_group.id
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
