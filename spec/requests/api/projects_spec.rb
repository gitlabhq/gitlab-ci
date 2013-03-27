require 'spec_helper'

describe GitlabCi::API do
  include ApiHelpers

  let(:user) { create(:user) }
  let!(:project) { create(:project) }

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
        json_response.first['always_build'].should == false
      end
    end
  end

  describe "POST /projects" do
    it "should create new project without path" do
      new_project = {
	:name => 'foo',
        :path => Rails.root.join('tmp', 'repositories', 'six').to_s,
        :scripts => 'ls',
        :timeout => 1800,
        :default_ref => 'master'
      }
      expect { post api("/projects", user), new_project }.to change {Project.count}.by(1)
    end

    it "should not create new project without name" do
      expect { post api("/projects", user) }.to_not change {Project.count}
    end

    it "should return a 400 error if name not given" do
      post api("/projects", user)
      response.status.should == 400
    end

    it "should respond with 201 on success" do
      new_project = {
        :name => 'foo',
        :path => Rails.root.join('tmp', 'repositories', 'six').to_s,
        :scripts => 'ls',
        :timeout => 1800,
        :default_ref => 'master'
      }
      post api("/projects", user), new_project
      response.status.should == 201
    end

    it "should assign attributes to project" do
      new_project = {
        :name => 'foo',
        :path => Rails.root.join('tmp', 'repositories', 'six').to_s,
        :scripts => 'ls',
        :timeout => 1800,
        :default_ref => 'master'
      }

      post api("/projects", user), new_project

      new_project.each_pair do |k,v|
        next if k == :path
        json_response[k.to_s].should == v
      end
    end
  end
end
