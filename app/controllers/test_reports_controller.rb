class TestReportsController < ApplicationController
  # GET /test_reports
  # GET /test_reports.json
  def index
    @test_reports = TestReport.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @test_reports }
    end
  end

  # GET /test_reports/1
  # GET /test_reports/1.json
  def show
    @test_report = TestReport.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @test_report }
    end
  end

  # GET /test_reports/new
  # GET /test_reports/new.json
  def new
    @test_report = TestReport.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @test_report }
    end
  end

  # GET /test_reports/1/edit
  def edit
    @test_report = TestReport.find(params[:id])
  end

  # POST /test_reports
  # POST /test_reports.json
  def create
    @test_report = TestReport.new(params[:test_report])

    respond_to do |format|
      if @test_report.save
        format.html { redirect_to @test_report, notice: 'Test report was successfully created.' }
        format.json { render json: @test_report, status: :created, location: @test_report }
      else
        format.html { render action: "new" }
        format.json { render json: @test_report.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /test_reports/1
  # PUT /test_reports/1.json
  def update
    @test_report = TestReport.find(params[:id])

    respond_to do |format|
      if @test_report.update_attributes(params[:test_report])
        format.html { redirect_to @test_report, notice: 'Test report was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @test_report.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /test_reports/1
  # DELETE /test_reports/1.json
  def destroy
    @test_report = TestReport.find(params[:id])
    @test_report.destroy

    respond_to do |format|
      format.html { redirect_to test_reports_url }
      format.json { head :no_content }
    end
  end
end
