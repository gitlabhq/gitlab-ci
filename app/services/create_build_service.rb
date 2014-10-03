class CreateBuildService
  def execute(project, params)
    before_sha = params[:before]
    sha = params[:after]
    ref = params[:ref]

    return nil unless ref and sha

    if ref.include?('refs/heads/')
      type = 'heads'
      ref = ref.scan(/heads\/(.*)$/).flatten[0]
    elsif ref.include?('refs/tags/')
      type = 'tags'
      ref = ref.scan(/tags\/(.*)$/).flatten[0]
      return nil unless params[:commits] # we require to have commits for specified ref
    else
      return nil # not supported other ref types
    end

    return nil if project.skip_ref?(ref, type)

    data = {
      ref: ref,
      ref_type: type,
      sha: sha,
      before_sha: before_sha,
      push_data: {
        before: params[:before],
        after: params[:sha],
        ref: params[:ref],
        user_name: params[:user_name],
        repository: params[:repository],
        commits: params[:commits],
        total_commits_count: params[:total_commits_count]
      }
    }

    project.builds.create(data)
  end
end
