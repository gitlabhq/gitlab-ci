require 'spec_helper'

describe API::API do
  include ApiHelpers
  include StubGitlabCalls

  before {
    stub_gitlab_calls
  }

  describe "GET /runners" do
    let(:gitlab_url) { GitlabCi.config.gitlab_server.url }
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
    describe "should create a runner if token provided" do
      before { post api("/runners/register"), token: GitlabCi::REGISTRATION_TOKEN }

      it { response.status.should == 201 }
    end

    describe "should create a runner if project token provided" do
      let(:project) { FactoryGirl.create(:project) }
      before { post api("/runners/register"), token: project.token }

      it { response.status.should == 201 }
      it { project.runners.size.should == 1 }
    end

    it "should return 403 error if token is invalid" do
      post api("/runners/register"), token: 'invalid'

      response.status.should == 403
    end

    it "should return 400 error if no token" do
      post api("/runners/register")

      response.status.should == 400
    end
  end
end
