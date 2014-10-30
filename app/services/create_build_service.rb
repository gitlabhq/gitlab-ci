require('travis_build_service')
require('shell_build_service')

class CreateBuildService
  def execute(project, params)
    params = params.push_data if params.kind_of?(Build)

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
        ref_message: params[:ref_message],
        build_method: project.build_method,
        push_data: {
            before: params[:before],
            after: params[:after],
            ref: params[:ref],
            user_name: params[:user_name],
            repository: params[:repository],
            commits: params[:commits],
            total_commits_count: params[:total_commits_count]
      }
    }

    build_service(project.build_method).execute(project, data)
  end

  def detect_build_method(project)
    CreateBuildService.local_constants.each do |build_class|
      build_service = CreateBuildService.const_get(build_class).new
      return build_class.downcase if build_service.detected?(project)
    end
    nil
  end

  def build_end(build)
    build_service(build.project.build_method).build_end(build)
  end

  def build_service(build_method)
    CreateBuildService.const_get(build_method.capitalize).new
  end
end
