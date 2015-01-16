class UserSessionsController < ApplicationController
  before_filter :authenticate_user!, except: [:new, :callback, :to_gitlab]

  def show
    @user = current_user
  end

  def new
  end

  def to_gitlab
    redirect_to client.auth_code.authorize_url({
      redirect_uri: callback_user_sessions_url
    })
  end

  def callback
    token = client.auth_code.get_token(params[:code], redirect_uri: callback_user_sessions_url).token
    
    @user_session = UserSession.new
    user = @user_session.authenticate(access_token: token, url: GitlabCi.config.gitlab_server.url)

    if user && sign_in(user)
      redirect_to root_path
    else
      @error = 'Invalid credentials'
      render :new
    end
    
  end

  def destroy
    sign_out

    redirect_to new_user_sessions_path
  end

  protected

  def client
    @client ||= ::OAuth2::Client.new(
      GitlabCi.config.gitlab_server.app_id,
      GitlabCi.config.gitlab_server.app_secret,
      {
        site: GitlabCi.config.gitlab_server.url,
        authorize_url: '/oauth/authorize',
        token_url: '/oauth/token'
      }
    )
  end
end
