require 'spec_helper'

describe "coverages/show" do
  before(:each) do
    @coverage = assign(:coverage, stub_model(Coverage,
      :file => "File",
      :lines => "Lines",
      :percentage => 1.5
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/File/)
    rendered.should match(/Lines/)
    rendered.should match(/1.5/)
  end
end
