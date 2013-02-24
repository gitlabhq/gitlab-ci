require 'spec_helper'

describe ProjectsController do
  let(:project) { FactoryGirl.create(:project) }
  let(:user) { FactoryGirl.create(:user) }
  subject { response }

  before { sign_in user }

  context "render edit project page" do
    before { get :edit, id: project.id }
    it { should be_success }
  end

  context "render edit github project page" do
    let(:project) { FactoryGirl.create(:github_project) }
    before { get :edit, id: project.id }
    it { should be_success }
  end
end
