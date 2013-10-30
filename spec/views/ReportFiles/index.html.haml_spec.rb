require 'spec_helper'

describe "test_reports/index" do
  before(:each) do
    assign(:ReportFiles, [
      stub_model(ReportFile,
        :testClass => "Test Class",
        :title => "Title",
        :duration => 1.5,
        :description => "Description",
        :status => "MyText"
      ),
      stub_model(ReportFile,
        :testClass => "Test Class",
        :title => "Title",
        :duration => 1.5,
        :description => "Description",
        :status => "MyText"
      )
    ])
  end

  it "renders a list of test_reports" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Test Class".to_s, :count => 2
    assert_select "tr>td", :text => "Title".to_s, :count => 2
    assert_select "tr>td", :text => 1.5.to_s, :count => 2
    assert_select "tr>td", :text => "Description".to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
  end
end
