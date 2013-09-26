require 'spec_helper'

describe API::API do
  include ApiHelpers

  let(:private_token) { "A" }
  let(:gitlab_url) { GitlabCi.config.allowed_gitlab_urls.first }
  let(:auth_url) { File.join(gitlab_url, Network::API_PREFIX, "user.json") }
  let(:options) {
    {
      :private_token => private_token,
      :url => gitlab_url
    }
  }

  before do
    # stub authentication endpoint
    stub_request(:get, auth_url).
      with(:body => { :private_token => private_token }).
      to_return(
      :status => 200,
      :headers => {"Content-Type" => "application/json"},
      :body => { :url => "http://myurl" }.to_json)
  end

  describe "GET /projects" do
    let(:project) { FactoryGirl.create(:project) }

    it "should return all projects on the CI instance" do
      get api("/projects"), options
      response.status.should == 200
      json_response.should == {}
    end
  end

  describe "GET /projects/:id" do
    let(:project) { FactoryGirl.create(:project) }

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

  describe "POST /projects" do
    let(:project_info) { {} }
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
  end

  describe "PUT /projects/:id" do
    let(:project) { FactoryGirl.create(:project) }
    let(:project_info) { {} }

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
      response.status.should == 400
    end
  end

  describe "DELETE /projects/:id" do
    let(:project) { FactoryGirl.create(:project) }

    before do
      project
    end

    it "should delete a specific project" do
      delete api("/projects/#{project.id}"), options
      response.status.should == 201 #?
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
      response.status.should == 201 #?

      project.reload
      project.runners.should be_empty
    end
  end
end
