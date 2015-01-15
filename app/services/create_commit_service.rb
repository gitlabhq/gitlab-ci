class CreateCommitService
  def execute(project, params)
    before_sha = params[:before]
    sha = params[:checkout_sha] || params[:after]
    origin_ref = params[:ref]

    unless origin_ref && sha.present?
      return false
    end

    ref = origin_ref.gsub(/\Arefs\/(tags|heads)\//, '')

    # Skip branch removal
    if sha == Git::BLANK_SHA
      return false
    end

    if project.skip_ref?(ref)
      return false
    end

    commit = project.commits.find_by(sha: sha)

    # Create commit if not exists yet
    unless commit
      data = {
        ref: ref,
        sha: sha,
        before_sha: before_sha,
        push_data: {
          before: before_sha,
          after: sha,
          ref: ref,
          user_name: params[:user_name],
          repository: params[:repository],
          commits: params[:commits],
          total_commits_count: params[:total_commits_count]
        }
      }

      commit = project.commits.create(data)
    end

    if origin_ref.start_with?('refs/tags/')
      commit.create_builds_for_tag(ref)
    else
      commit.create_builds
    end

    commit
  end
end
