require 'spec_helper'

describe 'Runner (github project)' do
  let(:user) { FactoryGirl.create :github_user }

  context "when repo missing" do
    it "should clone repo and run build" do
      build = setup_build_for_new_repo
      Runner.new.perform(build.id)

      build.reload
      build.trace.should include 'bundle install'
      build.should be_success
      build.project.repo_present?.should be
    end

    it "should run a failed build" do
      build = setup_build_for_new_repo
      runner = Runner.new
      runner.should_receive(:github_save_build_script!).and_return(['cat MISSING'])
      runner.perform(build.id)

      build.reload
      build.trace.should include '.ci_runner:'
      build.should be_failed
      build.project.repo_present?.should be
    end
  end

  context "when repo present" do
    it "should run build" do
      build = setup_build_for_existing_repo
      Runner.new.perform(build.id)

      build.reload
      build.trace.should include 'bundle install'
      build.should be_success
    end

    it "should run a failed build" do
      build = setup_build_for_existing_repo
      runner = Runner.new
      runner.should_receive(:github_save_build_script!).and_return(['cat MISSING'])
      runner.perform(build.id)

      build.reload
      build.trace.should include '.ci_runner:'
      build.should be_failed
      build.project.repo_present?.should be
    end
  end

  def setup_build_for_existing_repo
    build = setup_build false do |project|
      FileUtils.rm_rf project.path
      `git clone #{project.clone_url} #{project.path}` unless project.repo_present?
      project.repo_present?.should be
    end
    build
  end

  def setup_build_for_new_repo
    build = setup_build true do |project|
      FileUtils.rm_rf project.path
      project.repo_present?.should_not be
    end
    build
  end

  def setup_build is_new = false
    project = FactoryGirl.create :github_project,
      clone_url: Rails.root.join('tmp', 'test_repo').to_s,
      user:      user,
      name:      "evrone/test_repo"
    project.github?.should be
    project.path.scan(Rails.root.to_s).should be # GUARD
    yield project if block_given?
    project.register_build ref: 'master'
  end
end

