require 'spec_helper'

describe GitlabCi::API do
  include ApiHelpers

  let(:user) { create(:user) }
  let!(:project) { create(:project) }

  before { project.team << [user, :reporter] }

  describe "GET /projects" do
    context "when unauthenticated" do
      it "should return authentication error" do
        get api("/projects")
        response.status.should == 401
      end
    end

    context "when authenticated" do
      it "should return an array of projects" do
        get api("/projects", user)
        response.status.should == 200
        json_response.should be_an Array
        json_response.first['name'].should == project.name
        json_response.first['owner']['email'].should == user.email
      end
    end
  end

  describe "POST /projects" do
    it "should create new project without path" do
      expect { post api("/projects", user), name: 'foo' }.to change {Project.count}.by(1)
    end

    it "should not create new project without name" do
      expect { post api("/projects", user) }.to_not change {Project.count}
    end

    it "should return a 400 error if name not given" do
      post api("/projects", user)
      response.status.should == 400
    end

    it "should respond with 201 on success" do
      post api("/projects", user), name: 'foo'
      response.status.should == 201
    end

    it "should assign attributes to project" do
      project = attributes_for(:project, {
        description: Faker::Lorem.sentence,
        default_branch: 'stable',
        issues_enabled: false,
        wall_enabled: false,
        merge_requests_enabled: false,
        wiki_enabled: false
      })

      post api("/projects", user), project

      project.each_pair do |k,v|
        next if k == :path
        json_response[k.to_s].should == v
      end
    end
  end
end
