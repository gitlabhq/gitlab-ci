class HelpsController < ApplicationController
  skip_filter :check_config

  def show
  end

  def oauth2
    if valid_config?
      redirect_to root_path
    else
      render layout: 'empty'
    end
  end
end
