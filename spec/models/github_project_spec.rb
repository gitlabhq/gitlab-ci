require 'spec_helper'

describe GithubProject do
  let(:account) { FactoryGirl.create(:user_oauth_account, :github) }
  let(:user) { account.user.reload }
  let(:project) { FactoryGirl.create(:github_project) }
  subject { project }

  it { should be_valid }

  context ".store_repo_path" do
    it { GithubProject.store_repo_path.should == "#{Rails.root.to_s}/tmp/repos" }
  end

  context ".build_for_repo" do
    context "should build a new github project with" do
      let(:repo_params){ {
        name: "evrone/test",
        git: "git@github.com:evrone/test.git",
        id: 777
      } }
      subject { GithubProject.build_for_repo(user, repo_params) }

      it { should be_valid }
      its(:token) { should be }
      its(:clone_url) { should == repo_params[:git] }
      its(:name)  { should == repo_params[:name] }
      its(:github_repo_id) { should == repo_params[:id] }
    end
  end

  it "#add_deploy_key!"
  it "#add_hook!"
  it "#remove_existing_hooks!"
  it "#remove_existing_deploy_keys!"
  it "#register_build"
end

# == Schema Information
#
# Table name: projects
#
#  id               :integer(4)      not null, primary key
#  name             :string(255)     not null
#  path             :string(255)     not null
#  timeout          :integer(4)      default(1800), not null
#  scripts          :text            default(""), not null
#  created_at       :datetime        not null
#  updated_at       :datetime        not null
#  token            :string(255)
#  default_ref      :string(255)
#  gitlab_url       :string(255)
#  always_build     :boolean(1)      default(FALSE), not null
#  polling_interval :integer(4)
#  type             :string(255)
#  user_id          :integer(4)
#

