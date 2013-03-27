class UsersController < ApplicationController
  before_filter :authenticate_user!

  def index
    @users = User.all
    @new_user = User.new
  end

  def edit
  end

  def create
    @user = User.create(params[:user])

    redirect_to users_path
  end

  def update
    current_user.update_attributes(params[:user])

    redirect_to :back
  end

  def destroy
    User.find(params[:id]).destroy

    redirect_to users_path
  end

  def reset_private_token
    if current_user.reset_authentication_token!
      flash[:notice] = "Token was successfully updated"
    end

    redirect_to edit_user_path(current_user)
  end
end
