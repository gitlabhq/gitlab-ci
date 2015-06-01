require 'spec_helper'

describe API::API do
  include ApiHelpers

  let(:runner) { FactoryGirl.create(:runner) }
  let(:project) { FactoryGirl.create(:project) }

  describe "Builds API for runners" do
    let(:shared_runner) { FactoryGirl.create(:runner, token: "SharedRunner") }
    let(:shared_project) { FactoryGirl.create(:project, name: "SharedProject") }

    before do
      FactoryGirl.create :runner_project, project_id: project.id, runner_id: runner.id
    end

    describe "POST /builds/register" do
      it "should start a build" do
        commit = FactoryGirl.create(:commit, project: project)
        commit.create_builds
        build = commit.builds.first

        post api("/builds/register"), token: runner.token, info: {platform: :darwin}

        response.status.should == 201
        json_response['sha'].should == build.sha
        runner.reload.platform.should == "darwin"
      end

      it "should return 404 error if no pending build found" do
        post api("/builds/register"), token: runner.token

        response.status.should == 404
      end

      it "should return 404 error if no builds for specific runner" do
        commit = FactoryGirl.create(:commit, project: shared_project)
        FactoryGirl.create(:build, commit: commit, status: 'pending' )

        post api("/builds/register"), token: runner.token

        response.status.should == 404
      end

      it "should return 404 error if no builds for shared runner" do
        commit = FactoryGirl.create(:commit, project: project)
        FactoryGirl.create(:build, commit: commit, status: 'pending' )

        post api("/builds/register"), token: shared_runner.token

        response.status.should == 404
      end
    end

    describe "PUT /builds/:id" do
      let(:commit) { FactoryGirl.create(:commit, project: project)}
      let(:build) { FactoryGirl.create(:build, commit: commit, runner_id: runner.id) }

      it "should update a running build" do
        build.run!
        put api("/builds/#{build.id}"), token: runner.token
        response.status.should == 200
      end

      it 'Should not override trace information when no trace is given' do
        build.run!
        build.update!(trace: 'hello_world')
        put api("/builds/#{build.id}"), token: runner.token
        expect(build.reload.trace).to eq 'hello_world'
      end
    end
  end
end
