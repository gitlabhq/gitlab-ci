require 'spec_helper'

describe API::API do
  include ApiHelpers

  let(:project) { FactoryGirl.create(:project) }

  describe "GET /projects/:id" do
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

    context "with an existing project" do
      let(:request_url) { File.join(gitlab_url, Network::API_PREFIX, "projects", "#{project.id}.json") }

      before do
        # stub project endpoint
        stub_request(:get, request_url).
          with(:query => { :private_token => private_token }, headers: {"Content-Type" => "application/json"}).
          to_return(:body => {:id => project.id}.to_json, headers: {"Content-Type" => "application/json"})
      end

      it "should retrieve the project info" do
        get api("/projects/#{project.id}"), options
        response.status.should == 200
        json_response['id'].should == project.id
      end
    end

    context "with a non-existing project" do
      let(:request_url) { File.join(gitlab_url, Network::API_PREFIX, "projects/non_existent_id.json") }

      before do
        # stub project endpoint
        stub_request(:get, request_url).
          with(:query => { :private_token => private_token }, headers: {"Content-Type" => "application/json"}).
          to_return(:status => 404)
      end

      it "should return 404 error if project not found" do
        get api("/projects/non_existent_id"), options
        response.status.should == 404
      end
    end
  end
end
