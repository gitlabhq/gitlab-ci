require 'spec_helper'

describe "coverages/index" do
  before(:each) do
    assign(:coverages, [
      stub_model(Coverage,
        :file => "File",
        :lines => "Lines",
        :percentage => 1.5
      ),
      stub_model(Coverage,
        :file => "File",
        :lines => "Lines",
        :percentage => 1.5
      )
    ])
  end

  it "renders a list of coverages" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "File".to_s, :count => 2
    assert_select "tr>td", :text => "Lines".to_s, :count => 2
    assert_select "tr>td", :text => 1.5.to_s, :count => 2
  end
end
