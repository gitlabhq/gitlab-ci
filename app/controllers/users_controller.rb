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
    user_params = params[:user]

    if current_user.valid_password?(user_params.delete(:current_password))

      user_params.delete(:password) if user_params[:password].blank?
      user_params.delete(:password_confirmation) if user_params[:password_confirmation].blank?

      current_user.update_attributes(user_params)

      redirect_to :back
    else

      redirect_to :back, alert: 'Current password is invalid'
    end
  end

  def destroy
    User.find(params[:id]).destroy

    redirect_to users_path
  end
end
