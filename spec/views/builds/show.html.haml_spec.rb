require 'spec_helper'

describe "builds/show" do
  before(:each) do
    @build = assign(:build, stub_model(Build,
      :trace => "MyText",
      :status => "Status"
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/MyText/)
    rendered.should match(/Status/)
  end
end
