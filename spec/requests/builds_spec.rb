require 'spec_helper'

describe "Builds" do
  before do
    @project = FactoryGirl.create :project
    @commit = FactoryGirl.create :commit, project: @project
    @build = FactoryGirl.create :build, commit: @commit
  end

  describe "GET /:project/builds/:id/status.json" do
    before do
      get status_project_build_path(@project, @build), format: :json
    end

    it { expect(response.status).to eq 200 }
    it { expect(response.body).to include(@build.sha) }
  end
end
