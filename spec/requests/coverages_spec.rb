require 'spec_helper'

describe "Coverages" do
  describe "GET /coverages" do
    it "works! (now write some real specs)" do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      get coverages_path
      response.status.should be(200)
    end
  end
end
