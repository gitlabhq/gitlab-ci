require 'travis/yaml'
require 'travis/yaml/nodes/language'
require 'extension'

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

      build_group_data = data.dup
      build_group_data.delete(:build_method)
      build_group = project.build_groups.create(build_group_data)

      generate_builds(build_config_params, data, build_attributes) do |new_data, new_attributes, new_matrix_attributes|
        new_data.merge!(build_attributes: new_attributes)
        new_data.merge!(matrix_attributes: new_matrix_attributes)
        new_data.merge!(labels: build_labels(new_attributes))
        new_data.merge!(build_group_id: build_group.id)
        project.builds.create(new_data)
      end

      if build_group.builds.empty?
        build_group.drop
        build_group = nil
      end

      build_group
    end

    def detected?(project)
      load_config(project, 'HEAD', 'HEAD')
    end

    def build_commands(build)
      data = travis_config.dup
      build_attributes = Extension.deep_symbolize_keys(build.build_attributes)

      if build_attributes[:os]
        data[:config] = build_attributes
      else
        Extension.deep_merge!(data, build_attributes)
      end

      data[:urls] = {
      }
      data[:repository] = {
          source_url: build.repo_url,
          slug: build.repo_slug
      }
      data[:source] = {
          id: build.build_group.id,           # in future change it to buildgroup.id
          number: build.build_group.build_id  # in future change it to buildgroup.build_id (next number for current proejct)
      }
      data[:job] = {
          id: build.id,
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

    def format_build_attributes(build)
      build.build_attributes["config"].to_yaml.sub("---\n", '').gsub(/^:/, '') if build.build_attributes.is_a?(Hash) and build.build_attributes["config"]
    end

    def format_matrix_attributes(build)
      build.matrix_attributes.to_yaml.sub("---\n", '').gsub(/^:/, '') if build.matrix_attributes.is_a?(Hash) unless build.matrix_attributes.empty?
    end

    def build_labels(build_attributes)
      config = build_attributes['config']
      ['travis', config['os'], config['language']].join(" ")
    end

    def build_end(build)
      return unless build.build_group

      build_attributes = build.build_attributes
      config = build_attributes['config'] if build_attributes
      matrix_config = build_attributes['matrix'] if config

      # cancel all builds
      if matrix_config and matrix_config['fast_finish']
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

      @parameters = ::Travis::Yaml.parse(build_config_params)

      if @parameters.branches
        if @parameters.branches.only
          return unless @parameters.branches.only.include? data[:ref]
        elsif @parameters.branches.except
          return if @parameters.branches.except.include? data[:ref]
        end
      end

      ::Travis::Yaml.matrix(build_config_params).each do |matrix_entry|
        matrix_build_config = {}
        matrix_entry.mapping.each_key do |key|
          # call method to get matrix entry specialization for each mapped key
          # because Matrix::Entry redefines method for modified keys
          matrix_build_config[key] = matrix_entry.method(key).call()
        end

        if matrix_entry.respond_to? :matrix_attributes
          matrix_env = matrix_entry.matrix_attributes[:env]
          matrix_attributes = matrix_entry.matrix_attributes
        end
        matrix_env ||= @parameters.env.matrix if @parameters.env

        # workaround for broken matrix_entry.global
        inherited_env = @parameters.env.global if @parameters.env
        matrix_build_config['env'] = [*matrix_env, *inherited_env].compact

        # use eval to convert back to simple represtentation
        matrix_attributes = eval(matrix_attributes.to_s) if matrix_attributes

        # make it as data
        matrix_build_data = {}
        matrix_build_data['config'] = matrix_build_config
        matrix_build_data['env_vars'] = custom_attributes
        matrix_build_data = eval(matrix_build_data.to_s)

        block.call(data.dup, matrix_build_data, matrix_attributes)
      end
    end

    def url(project)
      project.gitlab_url.split('/')[0..-3].join('/')
    end

    def network
      @network ||= Network.new
    end
  end
end
