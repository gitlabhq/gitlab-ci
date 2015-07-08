class UserSessionsController < ApplicationController
  before_filter :authenticate_user!, except: [:new, :callback, :auth]

  def show
    @user = current_user
  end

  def new
  end

  def auth
    unless is_oauth_state_valid?(params[:state])
      redirect_to new_user_sessions_path
      return
    end

    redirect_to client.auth_code.authorize_url({
      redirect_uri: callback_user_sessions_url,
      state: params[:state]
    })
  end

  def callback
    unless is_oauth_state_valid?(params[:state])
      redirect_to new_user_sessions_path
      return
    end

    token = client.auth_code.get_token(params[:code], redirect_uri: callback_user_sessions_url).token
    
    @user_session = UserSession.new
    user = @user_session.authenticate(access_token: token)

    if user && sign_in(user)
      return_to = get_ouath_state_return_to(params[:state])
      redirect_to(return_to || root_path)
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
        authorize_url: 'oauth/authorize',
        token_url: 'oauth/token'
      }
    )
  end
end
