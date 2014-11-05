require 'spec_helper'

describe API::API, 'Commits' do
  include ApiHelpers

  let(:project) { FactoryGirl.create(:project) }
  let(:commit) { FactoryGirl.create(:commit, project: project) }

  let(:options) {
    {
      project_token: project.token,
      project_id: project.id
    }
  }

  describe "GET /commits" do
    before { commit }

    it "should return commits per project" do
      get api("/commits"), options

      response.status.should == 200
      json_response.count.should == 1
      json_response.first["project_id"].should == project.id
      json_response.first["sha"].should == commit.sha
    end
  end
end
