class BuildsController < ApplicationController
  before_filter :authenticate_user!, except :index, :show

  def index
    @builds = Build.all
  end

  def show
    @build = Build.find(params[:id])
  end

  def new
    @build = Build.new
  end

  def edit
    @build = Build.find(params[:id])
  end

  def create
    @build = Build.new(params[:build])

    respond_to do |format|
      if @build.save
        format.html { redirect_to @build, notice: 'Build was successfully created.' }
        format.json { render json: @build, status: :created, location: @build }
      else
        format.html { render action: "new" }
        format.json { render json: @build.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @build = Build.find(params[:id])

    respond_to do |format|
      if @build.update_attributes(params[:build])
        format.html { redirect_to @build, notice: 'Build was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @build.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @build = Build.find(params[:id])
    @build.destroy

    respond_to do |format|
      format.html { redirect_to builds_url }
      format.json { head :no_content }
    end
  end
end
