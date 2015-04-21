class UserSession
  include ActiveModel::Conversion
  include StaticModel
  extend ActiveModel::Naming

  def authenticate(auth_opts)
    authenticate_via(auth_opts) do |network, options|
      network.authenticate(options)
    end
  end

  def authenticate_by_token(auth_opts)
    result = authenticate_via(auth_opts) do |network, options|
      network.authenticate_by_token(options)
    end

    result
  end

  private

  def authenticate_via(options, &block)
    user = block.call(Network.new, options)

    if user
      return User.new(user)
    else
      nil
    end
  rescue
    nil
  end
end
