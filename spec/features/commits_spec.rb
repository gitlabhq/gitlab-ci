require 'spec_helper'

describe "Commits" do
  before do
    login_as :user
    @project = FactoryGirl.create :project
    @commit = FactoryGirl.create :commit, project: @project
    @job = FactoryGirl.create :job, project: @project
    @build = FactoryGirl.create :build, commit: @commit, job: @job
  end

  describe "GET /:project/commits/:sha" do
    before do
      visit project_show_commit_path(@project, sha: @commit.sha, ref: @commit.ref)
    end

    it { page.should have_content @commit.sha[0..7] }
    it { page.should have_content @commit.git_commit_message }
    it { page.should have_content @commit.git_author_name }
  end
end
