Rails.application.config.middleware.use OmniAuth::Builder do
  provider :github, Settings.try(:github).try(:client_id) || 1,
                    Settings.try(:github).try(:client_secret) || 2,
                    scope: "user,repo"
end

OmniAuth.config.logger = Rails.logger
