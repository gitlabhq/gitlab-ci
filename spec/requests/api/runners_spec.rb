require 'spec_helper'

describe API::API do
  include ApiHelpers
  include StubGitlabCalls
  
  before {
    stub_gitlab_calls
  }
  
  describe "GET /runners" do
    let(:gitlab_url) { GitlabCi.config.gitlab_server_urls.first }
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

    before do
      5.times { FactoryGirl.create(:runner) }
    end

    it "should retrieve a list of all runners" do
      get api("/runners"), options
      response.status.should == 200
      json_response.count.should == 5
      json_response.last.should have_key("id")
      json_response.last.should have_key("token")
    end
  end

  describe "POST /runners/register" do
    it "should create a runner if token provided" do
      post api("/runners/register"), token: GitlabCi::REGISTRATION_TOKEN, public_key: 'sha-rsa ....'

      response.status.should == 201
    end

    it "should return 403 error if no token" do
      post api("/runners/register")

      response.status.should == 403
    end
  end
end
