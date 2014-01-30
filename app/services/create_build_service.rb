class CreateBuildService
  def execute(project, params)
    before_sha = params[:before]
    sha = params[:after]
    ref = params[:ref]

    if ref && ref.include?('refs/heads/')
      ref = ref.scan(/heads\/(.*)$/).flatten[0]
    end

    data = {
      ref: ref,
      sha: sha,
      before_sha: before_sha,
      push_data: params
    }

    project.builds.create(data)
  end
end
