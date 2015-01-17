class HelpsController < ApplicationController
  before_filter :authenticate_user!
  skip_filter :check_config

  def show
  end

  def oauth2
  end
end
