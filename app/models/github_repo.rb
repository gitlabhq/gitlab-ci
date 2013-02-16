module GithubRepo
  class << self
    def all(user, force = false)
      collection = force ? nil : Collection.retrieve(user)
      unless collection
        collection = from_array(user.github_team_repositories + user.github_repositories)
        collection.store(user)
      end
      collection
    end

    def from_array(repos)
      Collection.new repos.select{|i| i.permissions["admin"] }
                          .uniq_by{|i| i.id }
                          .sort_by{|i| i.name }
                          .map{|r| Instance.new(r) }
    end

    def updated_at(user)
      value = GitlabCi.redis.get Collection.cache_key(user, :timestamp)
      Time.at(value.to_i) if value
    end

    def build!(user, repo_params)
      Builder.new(user, repo_params).build!
    end
  end

  class Collection < Array
    def self.cache_key(user, name)
      "#{Rails.env}:user:#{user.id}:github_repos:#{name}"
    end

    def self.retrieve(user)
      value = GitlabCi.redis.get cache_key(user, :all)
      YAML.load(value) if value
    end

    def cache_key(user, name)
      self.class.cache_key(user, name)
    end

    def store(user)
      GitlabCi.redis.set cache_key(user, :all), YAML.dump(self)
      GitlabCi.redis.set cache_key(user, :timestamp), Time.now.to_i
    end
  end

  class Instance
    attr_reader :id, :name, :description, :url, :git, :permissions, :private

    def initialize(repo)
      @id          = repo.id
      @name        = repo.full_name
      @private     = repo.private
      @description = repo.description
      @url         = repo.html_url
      @git         = repo.git_url
      @permissions = repo.permissions
    end

    def to_s
      @name
    end

    def to_data
      { id: @id, name: @name, url: @url, git: @git }
    end

    def to_param
      id
    end
  end

  class Builder
    def initialize(user, repo_params)
      @user      = user
      @params    = repo_params
      @repo_name = repo_params[:name]
      @key       = SSHKey.generate(:type => "RSA",
                                   :bits => 1024,
                                   :comment => public_key_name)
    end

    def build!
      begin
        remove_existing_hooks!
        add_hook!
        remove_existing_deploy_keys!
        add_deploy_key!
        self
      rescue Faraday::Error::ClientError => e
        Rails.logger.info e.response.inspect
        raise e
      end
    end

    def add_deploy_key!
      session.add_deploy_key(@repo_name,
                             public_key_name,
                             @key.ssh_public_key)
    end

    def add_hook!
      secret = Digest::MD5.hexdigest([@repo_name, hostname].join)
      config = {
        url: hook_url,
        secret: secret,
        content_type: "json"
      }
      options = {
        events: ["push", "pull_request"]
      }
      session.create_hook(@repo_name, "web", config, options)
    end

    def remove_existing_hooks!
      hooks = session.hooks(@repo_name).select do |hook|
        hook.config.url == hook_url
      end
      hooks.each do |hook|
        session.remove_hook(@repo_name, hook.id)
      end
      hooks
    end

    def remove_existing_deploy_keys!
      keys = session.deploy_keys(@repo_name).select do |key|
        key.title == public_key_name
      end
      keys.each do |key|
        session.remove_deploy_key(@repo_name, key.id)
      end
      keys
    end

    private
      def hook_url
        "http://#{hostname}/github_projects/hook"
      end

      def public_key_name
        hostname
      end

      def session
        @user.github_session
      end

      def hostname
        Settings.hostname
      end
  end
end
