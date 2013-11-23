require 'spec_helper'

describe "test_reports/show" do
  before(:each) do
    @report_files = assign(:report_files, stub_model(ReportFile,
      :testClass => "Test Class",
      :title => "Title",
      :duration => 1.5,
      :description => "Description",
      :status => "MyText"
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Test Class/)
    rendered.should match(/Title/)
    rendered.should match(/1.5/)
    rendered.should match(/Description/)
    rendered.should match(/MyText/)
  end
end
