require 'spec_helper'

describe "test_reports/edit" do
  before(:each) do
    @test_report = assign(:test_report, stub_model(TestReport,
      :filename => "MyString",
      :content => "MyString"
    ))
  end

  it "renders the edit test_report form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", test_report_path(@test_report), "post" do
      assert_select "input#test_report_filename[name=?]", "test_report[filename]"
      assert_select "input#test_report_content[name=?]", "test_report[content]"
    end
  end
end
