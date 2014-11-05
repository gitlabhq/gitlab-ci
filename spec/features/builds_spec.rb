require 'spec_helper'

describe "Builds" do
  before do
    login_as :user
    @project = FactoryGirl.create :project
    @commit = FactoryGirl.create :commit, project: @project
    @build = FactoryGirl.create :build, commit: @commit
  end

  describe "GET /:project/builds/:id" do
    before do
      visit project_build_path(@project, @build)
    end

    it { page.should have_content @commit.sha[0..7] }
    it { page.should have_content @commit.git_commit_message }
    it { page.should have_content @commit.git_author_name }
  end

  describe "GET /:project/builds/:id/cancel" do
    before do
      @build.run!
      visit cancel_project_build_path(@project, @build)
    end

    it { page.should have_content 'canceled' }
    it { page.should have_content 'Retry' }
  end

  describe "POST /:project/builds/:id/retry" do
    before do
      @build.cancel!
      visit project_build_path(@project, @build)
      click_link 'Retry'
    end

    it { page.should have_content 'pending' }
    it { page.should have_content 'Cancel' }
  end
end
