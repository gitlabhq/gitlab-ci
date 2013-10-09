require 'spec_helper'

describe API::API do
  include ApiHelpers

  let(:gitlab_url) { GitlabCi.config.allowed_gitlab_urls.first }
  let(:auth_opts) {
    {
      :email => "test@test.com",
      :password => "123456"
    }
  }

  let(:private_token) { Network.new.authenticate(gitlab_url, auth_opts)["private_token"] }
  let(:options) {
    {
      :private_token => private_token,
      :url => gitlab_url
    }
  }

  context "requests for scoped projects" do
    # NOTE: These ids are tied to the actual projects on demo.gitlab.com
    describe "GET /projects" do
      let!(:project1) { FactoryGirl.create(:project, :name => "gitlabhq", :gitlab_id => 3) }
      let!(:project2) { FactoryGirl.create(:project, :name => "gitlab-ci", :gitlab_id => 4) }

      it "should return all projects on the CI instance" do
        get api("/projects"), options
        response.status.should == 200
        json_response.count.should == 2
        json_response.first["id"].should == project1.id
        json_response.last["id"].should == project2.id
      end
    end

    describe "GET /projects/owned" do
      # NOTE: This user doesn't own any of these projects on demo.gitlab.com
      let!(:project1) { FactoryGirl.create(:project, :name => "gitlabhq", :gitlab_id => 3) }
      let!(:project2) { FactoryGirl.create(:project, :name => "random-project", :gitlab_id => 9898) }

      it "should return all projects on the CI instance" do
        get api("/projects/owned"), options

        response.status.should == 200
        json_response.count.should == 0
      end
    end
  end


  describe "GET /projects/:id" do
    let!(:project) { FactoryGirl.create(:project) }

    context "with an existing project" do
      it "should retrieve the project info" do
        get api("/projects/#{project.id}"), options
        response.status.should == 200
        json_response['id'].should == project.id
      end
    end

    context "with a non-existing project" do
      it "should return 404 error if project not found" do
        get api("/projects/non_existent_id"), options
        response.status.should == 404
      end
    end
  end

  describe "PUT /projects/:id" do
    let!(:project) { FactoryGirl.create(:project) }
    let!(:project_info) { {:name => "An updated name!" } }

    before do
      options.merge!(project_info)
    end

    it "should update a specific project's information" do
      put api("/projects/#{project.id}"), options
      response.status.should == 200
      json_response["name"].should == project_info[:name]
    end

    it "fails to update a non-existing project" do
      put api("/projects/non-existant-id"), options
      response.status.should == 404
    end
  end

  describe "DELETE /projects/:id" do
    let!(:project) { FactoryGirl.create(:project) }

    it "should delete a specific project" do
      delete api("/projects/#{project.id}"), options
      response.status.should == 200

      expect { project.reload }.to raise_error
    end
  end

  describe "POST /projects" do
    let(:project_info) {
      {
        :name => "My project",
        :gitlab_id => 1,
        :gitlab_url => "http://example.com/testing/testing",
        :ssh_url_to_repo => "ssh://example.com/testing/testing.git"
      }
    }

    let(:invalid_project_info) { {} }

    context "with valid project info" do
      before do
        options.merge!(project_info)
      end

      it "should create a project with valid data" do
        post api("/projects"), options
        response.status.should == 201
        json_response['name'].should == project_info[:name]
      end
    end

    context "with invalid project info" do
      before do
        options.merge!(invalid_project_info)
      end

      it "should error with invalid data" do
        post api("/projects"), options
        response.status.should == 400
      end
    end

    describe "POST /projects/:id/runners/:id" do
      let(:project) { FactoryGirl.create(:project) }
      let(:runner) { FactoryGirl.create(:runner) }

      it "should add the project to the runner" do
        post api("/projects/#{project.id}/runners/#{runner.id}"), options
        response.status.should == 201

        project.reload
        project.runners.first.id.should == runner.id
      end

      it "should fail if it tries to link a non-existing project or runner" do
        post api("/projects/#{project.id}/runners/non-existing"), options
        response.status.should == 404

        post api("/projects/non-existing/runners/#{runner.id}"), options
        response.status.should == 404
      end
    end

    describe "DELETE /projects/:id/runners/:id" do
      let(:project) { FactoryGirl.create(:project) }
      let(:runner) { FactoryGirl.create(:runner) }

      before do
        post api("/projects/#{project.id}/runners/#{runner.id}"), options
      end

      it "should remove the project from the runner" do
        project.runners.should be_present
        delete api("/projects/#{project.id}/runners/#{runner.id}"), options
        response.status.should == 200

        project.reload
        project.runners.should be_empty
      end
    end
  end
end
