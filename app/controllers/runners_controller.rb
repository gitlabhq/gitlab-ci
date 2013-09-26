class RunnersController < ApplicationController
  before_filter :authenticate_user!
  before_filter :runner, except: :index

  def index
    @runners = Runner.page(params[:page]).per(30)
  end

  def update
    @runner.update_attributes(description: params[:runner][:description])

    respond_to do |format|
      format.js
      format.html { redirect_to runners_path }
    end
  end

  def destroy
    Runner.find(params[:id]).destroy

    redirect_to runners_path
  end

  def assign_all
    Project.all.each { |project| @runner.assign_to(project, current_user) }

    respond_to do |format|
      format.js
      format.html { redirect_to runners_path, notice: "Runner was assigned to all projects" }
    end
  end

  def show
  end

  private

  def runner
    begin
      @runner ||= Runner.find(params[:id])
    rescue_from ActiveRecord::RecordNotFound do
      render :status => 404
    end
  end
end
