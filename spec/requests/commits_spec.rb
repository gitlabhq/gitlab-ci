require 'spec_helper'

describe "Commits" do
  before do
    @project = FactoryGirl.create :project
    @commit = FactoryGirl.create :commit, project: @project
  end

  describe "GET /:project/commits/:id/status.json" do
    before do
      get status_project_commit_path(@project, @commit), format: :json
    end

    it { response.status.should == 200 }
    it { response.body.should include(@commit.sha) }
  end
end
