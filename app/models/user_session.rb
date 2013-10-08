class UserSession
  include ActiveModel::Conversion
  include StaticModel
  extend ActiveModel::Naming

  attr_accessor :email, :password, :url

  def authenticate(auth_opts)
    authenticate_via(auth_opts) do |url, network, options|
      network.authenticate(url, options)
    end
  end

  def authenticate_by_token(auth_opts)
    result = authenticate_via(auth_opts) do |url, network, options|
      network.authenticate_by_token(url, options)
    end

    result
  end

  private

  def authenticate_via(options, &block)
    url = options.delete(:url)

    return nil unless GitlabCi.config.allowed_gitlab_urls.include?(url)

    user = block.call(url, Network.new, options)

    if user
      verified_options = user.merge({
        "url" => url,
        "private_token" => options[:private_token]
      })

      return User.new(verified_options)
    else
      nil
    end
  rescue
    nil
  end
end
