require 'rails_helper'

describe "Builds" do
  before do
    login_as :user
    @project = FactoryGirl.create :project
    @build = FactoryGirl.create :build, project: @project
  end

  describe "GET /:project/builds" do
    before do
      visit project_build_path(@project, @build)
    end

    it { expect(page).to have_content(@build.sha[0..7]) }
    it { expect(page).to have_content(@build.git_commit_message) }
    it { expect(page).to have_content(@build.git_author_name) }
  end
end
