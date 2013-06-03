class RunnersController < ApplicationController
  before_filter :authenticate_user!

  def index
    @runners = Runner.all
  end

  def destroy
    Runner.find(params[:id]).destroy

    redirect_to runners_path
  end
end
