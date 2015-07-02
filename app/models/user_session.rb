class UserSession
  include ActiveModel::Conversion
  include StaticModel
  extend ActiveModel::Naming

  def authenticate(auth_opts)
    network = Network.new
    user = network.authenticate(auth_opts)

    if user
      user["access_token"] = auth_opts[:access_token]
      return User.new(user)
    else
      nil
    end

    user
  rescue
    nil
  end
end
