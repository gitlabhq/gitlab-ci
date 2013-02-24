Octokit.configure do |config|
  config.auto_traversal = true
  if %w{ development test }.include?(Rails.env)
    config.faraday_config do |f|
      f.use Faraday::Response::Logger, Rails.logger
      f.use Faraday::Response::RaiseError
    end
  end
end

module GitlabCi
  class << self
    def github_deploy_key
      @github_deploy_key ||= File.read(File.expand_path("~/.ssh/id_rsa.pub")).strip
    end
  end
end

