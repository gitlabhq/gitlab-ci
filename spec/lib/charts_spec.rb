require 'rails_helper'

describe "Charts" do

  context "build_times" do
    before do
      @project = FactoryGirl.create(:project)
      FactoryGirl.create(:build, :project_id => @project.id)
    end

    it 'should return build times in minutes' do
      chart = Charts::BuildTime.new(@project)
      expect(chart.build_times).to eq([2])
    end
  end
end
