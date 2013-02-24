require 'spec_helper'

describe "Sign in with Github" do
  omniauth_mock_request(:github, '123')

  before do
  end

  context "when a new user" do
    it "should create the user and sign in" do
      visit root_path
      expect {
        click_link "Sign in with Github"
      }.to change{ UserOauthAccount.count }.by(1)
      current_path.should == '/'
    end
  end

  context "when existing user" do
    let!(:account){ FactoryGirl.create(:user_oauth_account, uid:'123') }
    it "should sign in the user" do
      visit root_path
      expect {
        click_link "Sign in with Github"
      }.to_not change{ UserOauthAccount.count }.by(1)
      current_path.should == '/'
    end
  end
end
