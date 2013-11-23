class ReportFilesController < ApplicationController
  # GET /report_files
  # GET /report_files.json
  def index
    @report_files = ReportFile.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @report_files }
    end
  end

  # GET /report_files/1
  # GET /report_files/1.json
  def show
    @report_files = ReportFile.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @report_files }
    end
  end

end
