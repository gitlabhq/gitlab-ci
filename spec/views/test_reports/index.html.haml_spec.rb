require 'spec_helper'

describe "test_reports/index" do
  before(:each) do
    assign(:test_reports, [
      stub_model(TestReport,
        :filename => "Filename",
        :content => "Content"
      ),
      stub_model(TestReport,
        :filename => "Filename",
        :content => "Content"
      )
    ])
  end

  it "renders a list of test_reports" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Filename".to_s, :count => 2
    assert_select "tr>td", :text => "Content".to_s, :count => 2
  end
end
