module GitlabCi
  class << self
    def redis
      unless @redis
        config_file = Rails.root.join('config', 'resque.yml')

        resque_url = if File.exists?(config_file)
                       "redis://" + YAML.load_file(config_file)[Rails.env]
                     else
                       "localhost:6379"
                     end
        @redis = Redis.new url: resque_url
      end
      @redis
    end
  end
end
