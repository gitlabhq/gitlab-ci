module UserSessionsHelper
  def generate_oauth_salt
    SecureRandom.hex(16)
  end

  def generate_oauth_secret(salt, return_to)
    return unless return_to
    message = GitlabCi::Application.config.secret_key_base + salt + return_to
    Digest::SHA256.hexdigest message
  end

  def generate_oauth_state(return_to)
    return unless return_to
    salt = generate_oauth_salt
    secret = generate_oauth_secret(salt, return_to)
    "#{salt}:#{secret}:#{return_to}"
  end

  def get_ouath_state_return_to(state)
    state.split(':', 3)[2] if state
  end

  def is_oauth_state_valid?(state)
    return true unless state
    salt, secret, return_to = state.split(':', 3)
    return false unless return_to
    secret == generate_oauth_secret(salt, return_to)
  end
end
