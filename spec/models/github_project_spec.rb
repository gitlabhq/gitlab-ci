require 'spec_helper'

describe GithubProject do
  let(:account) { FactoryGirl.create(:user_oauth_account, :github) }
  let(:user) { account.user.reload }
  let(:project) { FactoryGirl.create(:github_project) }
  subject { project }

  it "#add_deploy_key!"
  it "#add_hook!"
  it "#remove_existing_hooks!"
  it "#remove_existing_deploy_keys!"
  it "#register_build"
  it "#save_with_github_repo!"

  it { should be_valid }

  it { GithubProject.store_repo_path.should == "#{Rails.root.to_s}/tmp/repos" }
  it { GithubProject.git_ssh_command.should be_include("ci_git_ssh") }
  it { GithubProject.store_repo_path.should be_include("tmp/repos") }

  its(:deploy_key_name) { should be }
  its(:hook_url)        { should be }
  its(:path)            { should be }

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

  context "#store_ssh_keys!" do
    subject { project.store_ssh_keys! }

    it { File.exists?(subject).should be }

    it "with directory mask 0700" do
      dir_mode(subject).should == '40700'
    end

    it "with file mask 0600" do
      file_mode(subject).should == '100600'
    end

    it "with content" do
      File.read(subject).should == project.private_key
    end

    after do
      File.unlink(subject) if subject
    end
  end

  context "#clean_ssh_keys!" do
    let(:path) { project.store_ssh_keys! }
    subject { project.clean_ssh_keys! }

    before do
      path.should be
      File.exists?(path).should be
    end

    it { File.exists?(subject).should_not be }
  end

  context "#generate_ssh_keys" do
    subject { project.generate_ssh_keys }
    it "make a new public key" do
      expect{ subject }.to change{ project.public_key }
    end
    it "make a new private key" do
      expect{ subject }.to change{ project.private_key }
    end
  end

  def file_mode(file)
    sprintf("%o", File.stat(file).mode)
  end

  def dir_mode(dir)
    file_mode(File.dirname dir)
  end

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

