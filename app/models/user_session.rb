class UserSession
  include ActiveModel::Conversion
  include StaticModel
  include HTTParty
  extend ActiveModel::Naming

  attr_accessor :email, :password, :url

  def authenticate auth_opts
    url = auth_opts.delete(:url)

    opts = {
      body: auth_opts.to_json,
      headers: {"Content-Type" => "application/json"},
    }

    response = self.class.post(url + 'api/v3/session.json', opts)

    if response.code == 201
      response
    else
      nil
    end
  end
end
