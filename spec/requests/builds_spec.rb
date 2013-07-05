require 'spec_helper'

describe API::API do
  include ApiHelpers

  let(:runner) { FactoryGirl.create(:runner) }
  let(:project) { FactoryGirl.create(:project) }

  before do
    FactoryGirl.create :runner_project, project_id: project.id, runner_id: runner.id
  end

  describe "POST /builds/register" do
    it "should start a build" do
      build = FactoryGirl.create(:build, project_id: project.id, status: 'pending' )

      post api("/builds/register"), token: runner.token

      response.status.should == 201
      json_response['sha'].should == build.sha
    end

    it "should return 404 error if no pending build found" do
      post api("/builds/register"), token: runner.token

      response.status.should == 404
    end
  end

  describe "PUT /builds/:id" do
    let(:build) { FactoryGirl.create(:build, project_id: project.id) }

    it "should update a build" do
      put api("/builds/#{build.id}"), token: runner.token
      response.status.should == 200
    end
  end
end
