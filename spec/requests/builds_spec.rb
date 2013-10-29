require 'spec_helper'

describe API::API do
  include ApiHelpers

  let(:runner) { FactoryGirl.create(:runner) }
  let(:project) { FactoryGirl.create(:project) }

  describe "Builds API for runners" do
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
      let(:build) { FactoryGirl.create(:build, project_id: project.id, runner_id: runner.id) }

      it "should update a running build" do
        build.run!
        put api("/builds/#{build.id}"), token: runner.token
        response.status.should == 200
      end
    end
  end

  describe "POST /builds" do
    let(:data) {
      {
        "before" => "95790bf891e76fee5e1747ab589903a6a1f80f22",
        "after" => "da1560886d4f094c3e6c9ef40349f7d38b5d27d7",
        "ref" => "refs/heads/master",
        "commits" => [
          {
            "id" => "b6568db1bc1dcd7f8b4d5a946b0b91f9dacd7327",
            "message" => "Update Catalan translation to e38cb41.",
            "timestamp" => "2011-12-12T14:27:31+02:00",
            "url" => "http://localhost/diaspora/commits/b6568db1bc1dcd7f8b4d5a946b0b91f9dacd7327",
            "author" => {
              "name" => "Jordi Mallach",
              "email" => "jordi@softcatala.org",
            }
          }
        ]
      }
    }

    it "should create a build" do
      post api("/builds"), project_id: project.id, data: data, project_token: project.token

      response.status.should == 201
      json_response['sha'].should == "da1560886d4f094c3e6c9ef40349f7d38b5d27d7"
    end

    it "should return 400 error if no data passed" do
      post api("/builds"), project_id: project.id, project_token: project.token

      response.status.should == 400
      json_response['message'].should == "400 (Bad request) \"data\" not given"
    end
  end
end
