class UserSession
  include ActiveModel::Conversion
  include StaticModel
  extend ActiveModel::Naming

  attr_accessor :email, :password, :url

  def authenticate auth_opts
    url = auth_opts.delete(:url)

    return nil unless GitlabCi.config.allowed_gitlab_urls.include?(url)

    user = Network.new.authenticate(url, auth_opts)

    if user
      user[:url] = url
      OpenStruct.new(user)
    else
      nil
    end
  end
end
