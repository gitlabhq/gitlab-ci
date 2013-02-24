class OmniauthCallbacksController < ApplicationController

  def create
    if @account = UserOauthAccount.where(provider:"github", uid:user_uid).first
      @account.restrict!
      sign_in_and_redirect(:user, @account.user)
    else
      @user = UserOauthAccount.register_user!('github', auth_hash) do |account|
        account.restrict!
      end
      sign_in_and_redirect(:user, @user)
    end
  end

  protected

    def auth_hash
      ActiveSupport::HashWithIndifferentAccess.new(request.env['omniauth.auth'])
    end

    def user_uid
      auth_hash[:uid]
    end

    def user_token
      auth_hash[:token]
    end

end
