require 'spec_helper'

describe 'Runner (github project)' do
  let(:user) { FactoryGirl.create :github_user }
  before do
  end

  context "when repo missing" do
    it "should clone repo and run build" do
      build = setup_build "ls", true do |project|
        FileUtils.rm_rf project.path
        project.repo_present?.should_not be
      end

      Runner.new.perform(build.id)

      build.reload
      build.trace.should include 'bundle install'
      build.should be_success
      build.project.repo_present?.should be
    end
  end

  context "when repo present" do
    it "should run build" do
      build = setup_build "ls" do |project|
        FileUtils.rm_rf project.path
        `git clone #{project.clone_url} #{project.path}` unless project.repo_present?
        project.repo_present?.should be
      end

      Runner.new.perform(build.id)

      build.reload
      build.trace.should include 'bundle install'
      build.should be_success
    end
  end

  def setup_build cmd, is_new = false
    project = FactoryGirl.create :github_project,
      scripts: cmd,
      clone_url: Rails.root.join('tmp', 'test_repo').to_s,
      user: user,
      name: "evrone/test_repo"
    project.github?.should be
    project.path.scan(Rails.root.to_s).should be # GUARD
    yield project if block_given?
    project.register_build ref: 'master'
  end
end

