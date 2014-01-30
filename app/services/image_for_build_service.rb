class ImageForBuildService
  def execute(project, params)
    if params[:sha]
      # Look for last build if commit sha provided
      build = project.last_build_for_sha(params[:sha])
      image_name = image_for_build(build)
    elsif params[:ref]
      # Look for last build per branch
      build = project.builds.where(ref: params[:ref]).last
      image_name = image_for_build(build)
    else
      image_name = 'unknown.png'
    end

    image_path = Rails.root.join('public', image_name)

    OpenStruct.new(
      path: image_path,
      name: image_name
    )
  end

  private

  def image_for_build(build)
    return 'unknown.png' unless build

    if build.success?
      'success.png'
    elsif build.failed?
      'failed.png'
    elsif build.active?
      'running.png'
    else
      'unknown.png'
    end
  end
end
