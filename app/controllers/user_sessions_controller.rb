class UserSessionsController < ApplicationController
  def show
    @user_session = UserSession.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @user_session }
    end
  end

  def new
    @user_session = UserSession.new
  end

  def create
    @user_session = UserSession.new
    user = @user_session.authenticate(params[:user_session])

    if user && sign_in(user)
      redirect_to root_path
    else
      render :new
    end
  end

  def destroy
    @user_session = UserSession.find(params[:id])
    @user_session.destroy

    respond_to do |format|
      format.html { redirect_to user_sessions_url }
      format.json { head :no_content }
    end
  end
end
