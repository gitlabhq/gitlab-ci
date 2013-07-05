require 'spec_helper'

describe API::API do
  include ApiHelpers

  describe "POST /runners/register" do
    it "should create a runner if token provided" do
      post api("/runners/register"), token: GitlabCi::RunnersToken, public_key: 'sha-rsa ....'

      response.status.should == 201
    end

    it "should return 403 error if no token" do
      post api("/runners/register")

      response.status.should == 403
    end
  end
end
