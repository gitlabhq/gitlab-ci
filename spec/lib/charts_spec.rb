require 'spec_helper'

describe "Charts" do

  context "build_times" do
    before do
      @project = FactoryGirl.create(:project)
      FactoryGirl.create(:build, :project_id => @project.id)
    end

    it 'should return build times in minutes' do
      chart = Charts::BuildTime.new(@project)
      chart.build_times.should == [2]
    end
  end
end
