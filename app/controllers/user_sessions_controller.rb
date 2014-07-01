class UserSessionsController < ApplicationController
  before_filter :authenticate_user!, except: [:new, :create]

  def show
    @user = current_user
  end

  def new
    @user_session = UserSession.new
  end

  def create
    @user_session = UserSession.new
    user = @user_session.authenticate(params[:user_session])

    @return_to = params[:return_to] if params[:return_to].present?

    if user && sign_in(user)
      redirect_to @return_to || root_path
    else
      @error = 'Invalid credentials'
      render :new
    end
  end

  def destroy
    sign_out

    redirect_to new_user_sessions_path
  end
end
