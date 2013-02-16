module OmniauthHelpers
  def omniauth_mock_request(provider, uid)
    before do
      OmniAuth.config.mock_auth[provider] = {
        'uid'         => uid.to_s,
        'provider'    => provider.to_s,
        'credentials' => {
          'token' => 'token'
        },
        'info'        => {
          'nickname' => 'nickname'
        }
      }
    end
  end
end
