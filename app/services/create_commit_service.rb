class CreateCommitService
  def execute(project, params)
    before_sha = params[:before]
    sha = params[:checkout_sha] || params[:after]
    origin_ref = params[:ref]
    yaml_config = params[:ci_yaml_file] || project.generated_yaml_config
    config_processor = build_config_processor(yaml_config)

    unless origin_ref && sha.present?
      return false
    end

    ref = origin_ref.gsub(/\Arefs\/(tags|heads)\//, '')

    # Skip branch removal
    if sha == Git::BLANK_SHA
      return false
    end

    if params[:commits] && params[:commits].last[:message] =~ /(\[ci skip\])/
      return false
    end

    if origin_ref.start_with?('refs/tags/') && !config_processor.create_commit_for_tag?(ref)
      return false
    end

    if config_processor.skip_ref?(ref)
      return false
    end

    commit = project.commits.find_by_sha_and_ref(sha, ref)

    # Create commit if not exists yet
    unless commit
      data = {
        ref: ref,
        sha: sha,
        tag: origin_ref.start_with?('refs/tags/'),
        before_sha: before_sha,
        push_data: {
          before: before_sha,
          after: sha,
          ref: ref,
          user_name: params[:user_name],
          user_email: params[:user_email],
          repository: params[:repository],
          commits: params[:commits],
          total_commits_count: params[:total_commits_count],
          ci_yaml_file: yaml_config
        }
      }

      commit = project.commits.create(data)
    end

    commit.create_builds unless commit.builds.any?

    if commit.builds.empty?
      commit.create_deploy_builds
    end

    commit
  end

  private

  def build_config_processor(config_data)
    @builds_config ||= GitlabCiYamlProcessor.new(config_data)
  end
end
