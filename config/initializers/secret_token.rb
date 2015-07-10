# Be sure to restart your server when you modify this file.

require 'securerandom'

# Your secret key for verifying the integrity of signed cookies and encryption database variables.
# If you change or lose this key, you will lose also all encrypted data!
# Ensue that you backup the `config/secrets.yml` in some place secure.

def generate_new_secure_token
  SecureRandom.hex(64)
end

def find_old_secure_token
  token_file = Rails.root.join('.secret')
  if File.exist? token_file
    # Use the existing token.
    File.read(token_file).chomp
  else
    # Generate a new token of 64 random hexadecimal characters and store it in token_file.
    token = generate_new_secure_token
    File.write(token_file, token)
    token
  end
end

if GitlabCi::Application.secrets.secret_key_base.blank? || GitlabCi::Application.secrets.db_key_base.blank?
  warn "Missing `secret_key_base` or `db_key_base` for '#{Rails.env}' environment. The secrets will be generated and stored in `config/secrets.yml`"

  all_secrets = YAML.load_file('config/secrets.yml') if File.exist?('config/secrets.yml')
  all_secrets ||= {}

  # generate secrets
  env_secrets = all_secrets[Rails.env] || {}
  env_secrets['secret_key_base'] ||= find_old_secure_token
  env_secrets['db_key_base'] ||= generate_new_secure_token
  all_secrets[Rails.env] = env_secrets

  # save secrets
  File.open('config/secrets.yml', 'w') do |file|
    file.write(YAML.dump(all_secrets))
  end

  GitlabCi::Application.secrets.secret_key_base = env_secrets['secret_key_base']
  GitlabCi::Application.secrets.db_key_base = env_secrets['db_key_base']
end
