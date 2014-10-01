class CreateBuildService
  def execute(project, params)
    before_sha = params[:before]
    sha = params[:after]
    ref = params[:ref]

    if ref && ref.include?('refs/heads/')
      ref = ref.scan(/heads\/(.*)$/).flatten[0]
    end

    return false if project.skip_ref?(ref)

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

    project.builds.create(data)
  end
end
