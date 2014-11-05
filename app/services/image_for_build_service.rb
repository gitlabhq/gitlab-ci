class ImageForBuildService
  def execute(project, params)
    image_name =
      if params[:sha]
        commit = project.commits.find_by(sha: params[:sha])
        image_for_commit(commit)
      elsif params[:ref]
        commit = project.last_commit_for_ref(params[:ref])
        image_for_commit(commit)
      else
        'unknown.png'
      end

    image_path = Rails.root.join('public', image_name)

    OpenStruct.new(
      path: image_path,
      name: image_name
    )
  end

  private

  def image_for_commit(commit)
    return 'unknown.png' unless commit

    commit.status + ".png"
  end
end
