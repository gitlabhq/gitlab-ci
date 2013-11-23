class CoveragesController < ApplicationController
  # GET /coverages
  # GET /coverages.json
  def index
    @coverages = Coverage.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @coverages }
    end
  end

  # GET /coverages/1
  # GET /coverages/1.json
  def show
    @coverage = Coverage.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @coverage }
    end
  end

end
