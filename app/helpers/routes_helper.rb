module RoutesHelper
  class Base
    include Rails.application.routes.url_helpers

    def default_url_options
      {
        host: Settings.gitlab_ci['host'],
        protocol: Settings.gitlab_ci['https'] ? "https" : "http",
        port: Settings.gitlab_ci['port']
      }
    end
  end

  def url_helpers
    @url_helpers ||= Base.new
  end

  def self.method_missing(method, *args, &block)
    @url_helpers ||= Base.new

    if @url_helpers.respond_to?(method)
      @url_helpers.send(method, *args, &block)
    else
      super method, *args, &block
    end
  end
end
