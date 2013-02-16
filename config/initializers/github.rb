if %{ develoment test }.include?(Rails.env)
  Octokit.configure do |config|
    config.faraday_config do |f|
      f.use Faraday::Response::Logger, Rails.logger
    end
  end
end

module GitlabCi
  class << self
    def github(account)
      @github ||= {}
      @github[account.id] ||= Octokit::Client.new(:login => account.name,
                                                  :oauth_token => account.token)
    end
  end
end

