# Be sure to restart your server when you modify this file.

# Your secret key is used for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid!

# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.
# You can use `rake secret` to generate a secure secret key.

# Make sure your secret_key_base is kept private
# if you're sharing your code publicly.
GitlabCi::Application.config.secret_key_base = '41cff934d5a788409310b2b4dc931ca9be9c5113ede94f41d44bf71b403f007d8031efa855d6d111393d33ca839722db98445a1a6f020331a3f43bd29a50c93e'
