require 'spec_helper'

describe "test_reports/show" do
  before(:each) do
    @test_report = assign(:test_report, stub_model(TestReport,
      :filename => "Filename",
      :content => "Content"
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Filename/)
    rendered.should match(/Content/)
  end
end
