require 'spec_helper'

describe GithubProjectsController do
  subject { response }

  context "render new project page" do
    context "when user without github account" do
      let(:user) { FactoryGirl.create(:user) }
      before do
        sign_in user
        get :new
      end
      it { should redirect_to(new_project_path) }
    end

    context "when user with github account" do
      let(:user) { FactoryGirl.create(:user_oauth_account).user }
      before do
        sign_in user
        get :new
      end
      it { should be_success }
    end
  end

end
