require 'spec_helper'

describe "builds/index" do
  before(:each) do
    assign(:builds, [
      stub_model(Build,
        :trace => "MyText",
        :status => "Status"
      ),
      stub_model(Build,
        :trace => "MyText",
        :status => "Status"
      )
    ])
  end

  it "renders a list of builds" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    assert_select "tr>td", :text => "Status".to_s, :count => 2
  end
end
