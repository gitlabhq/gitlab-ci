require 'digest/md5'

class UserOauthAccount < ActiveRecord::Base
  attr_accessible :link, :name, :provider, :secret, :token, :uid, :user_id
  belongs_to :user
  validates :user_id, :provider, :token, :uid, :presence => true

  scope :github, -> { where(provider: "github") }

  class << self
    def register_user!(provider, auth_hash)
      transaction do
        uid = auth_hash[:uid]
        password = Digest::MD5.hexdigest(rand.to_s)
        email    = email_by_uid_provider(uid, provider)
        token    = auth_hash[:credentials][:token]
        name     = auth_hash[:info][:nickname]
        user = User.create!(
          email: email,
          password: password,
          password_confirmation: password
        )
        account = user.create_user_oauth_account!(
          provider: provider,
          uid: uid,
          token: token,
          name: name
        )
        yield account if block_given?
        user
      end
    end

    def email_by_uid_provider(uid, provider)
      "#{provider}.#{uid}@example.com"
    end
  end

  def github?
    provider == 'github'
  end

  def restrict!
    orgs = Settings.github.restrict
    unless orgs.blank?
      if (orgs & user.github_organization_names).blank?
        raise(DenyByRestriction, "#{uid} #{orgs.inspect} #{member_ids.inspect}")
      end
    end
  end

  class DenyByRestriction < Exception ; end
end
