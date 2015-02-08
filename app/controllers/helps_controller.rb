class HelpsController < ApplicationController
  skip_filter :check_config

  def show
  end

  def oauth2
    render layout: "empty"
  end
end
