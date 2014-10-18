require 'travis/model/build/config'
require 'travis/model/build/config/matrix'

class CreateBuildService
  class Travis
    def execute(project, data)
      build_attributes = Array.new
      project.travis_environment.shellsplit.each do |env|
        key, value = env.split('=', 2)
        public = key[0] != '@'
        key = key.gsub(/^@/, '')
        build_attributes << {name: key, value: value, public: public}
      end

      build_config_params = load_config(project, data[:sha], data[:ref_type] == 'tags')
      return nil if build_config_params.nil?

      ActiveRecord::Base.transaction do
        begin
          build_group_data = data.dup
          build_group_data.delete(:build_method)
          build_group = project.build_groups.create(build_group_data)

          generate_builds(build_config_params, data, build_attributes) do |new_data, new_attributes|
            new_data.merge!(build_attributes: new_attributes)
            new_data.merge!(build_os: new_attributes[:config][:os] || 'linux')
            new_data.merge!(build_image: build_image(new_attributes))
            new_data.merge!(build_group_id: build_group.id)
            project.builds.create(new_data)
          end

          if build_group.builds.empty?
            raise ActiveRecord::Rollback
          end

          build_group
        rescue
          raise ActiveRecord::Rollback
          nil
        end
      end
    end

    def detected?(project)
      load_config(project, 'HEAD', 'HEAD')
    end

    def build_commands(build)
      data = travis_config.dup
      data[:config] = build.build_attributes[:config]
      data[:env_vars] = (data[:env_vars] || []) + (build.build_attributes[:env_vars] || {})

      data[:urls] = {
      }
      data[:repository] = {
          source_url: build.repo_url,
          slug: build.repo_slug
      }
      data[:source] = {
          id: build.build_group.id.to_s,           # in future change it to buildgroup.id
          number: build.build_group.build_id.to_s  # in future change it to buildgroup.build_id (next number for current proejct)
      }
      data[:job] = {
          id: build.id.to_s,
          number: "#{build.build_id}.#{build.build_concurrent_id}",
          branch: build.ref,
          commit: build.sha,
          commit_range: "#{build.short_before_sha}..#{build.short_sha}",
          pull_request: false, # not yet supported
          tag: build.tag? ? build.ref : nil
      }

      script = ::Travis::Build.script(data, logs: { build: true, state: false })
      script.compile
    end

    def custom_commands(build)
      true
    end

    def format_build_attributes(build)
      build_config = build.build_attributes[:config] if build.build_attributes
      build_config = build_config.to_yaml.sub("---\n", '').gsub(/^:/, '') if build_config
      build_config
    end

    def format_matrix_attributes(build)
      matrix_config = build.build_attributes[:matrix_config] if build.build_attributes
      matrix_config = matrix_config.to_yaml.sub("---\n", '').gsub(/^:/, '') if matrix_config
      matrix_config
    end

    def build_image(build_attributes)
      config = build_attributes[:config] || {}
      "ayufan/travis-#{config[:os]}-worker:#{config[:language]}"
    end

    def build_end(build)
      return unless build.build_group

      build_attributes = build.build_attributes
      config = build_attributes[:config] if build_attributes
      matrix_config = build_attributes[:matrix] if config
      fast_finish = matrix_config[:fast_finish] if fast_finish

      # cancel all builds
      if fast_finish
        build.build_group.builds.each do |other_build|
          other_build.cancel
        end
      end
    end

    private

    def travis_config
      @travis_config ||= Extension.deep_symbolize_keys(YAML.load_file("#{Rails.root}/config/travis.yml")[Rails.env])
    end

    def load_config(project, sha, is_tagged = false)
      config_file = network.raw_file_content(url(project), project.gitlab_id, project.private_token, sha, '.release.yml') if is_tagged
      config_file ||= network.raw_file_content(url(project), project.gitlab_id, project.private_token, sha, '.travis.yml')
      YAML.load(config_file) unless config_file.nil?
    end

    def generate_builds(build_config_params, data, custom_attributes, &block)
      raise 'block must be specified' unless block_given?
      ``

      build_config = ::Travis::Model::Build::Config.new(build_config_params, default_options).normalize
      if branches=build_config[:branches]
        if branches[:only]
          return unless branches[:only].include? data[:ref]
        elsif branches[:except]
          return if branches[:except].include? data[:ref]
        end
      end

      # omit gh-pages unless specified in branches.only
      return if data[:ref] == 'gh-pages' unless build_config[:branches] and build_config[:branches][:only]

      matrix_build = ::Travis::Model::Build::Config::Matrix.new(build_config, default_options)
      matrix_build.expand.each do |expanded_config|
        matrix_attributes = expanded_config.select do |key, value|
          matrix_build.send(:expand_keys).include? key and build_config[key].is_a?(Array)
        end

        matrix_build_data = {
            config: expanded_config,
            matrix_config: matrix_attributes,
            env_vars: custom_attributes,
        }

        block.call(data.dup, matrix_build_data)
      end
    end

    def url(project)
      project.gitlab_url.split('/')[0..-3].join('/')
    end

    def network
      @network ||= Network.new
    end

    def default_options
      {multi_os: true, dist_group_expansion: true}
    end
  end
end
