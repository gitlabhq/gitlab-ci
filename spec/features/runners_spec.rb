require 'spec_helper'

describe "Runners" do
  before do
    login_as :user
    @project = FactoryGirl.create :project
  end

  describe "GET /projects/:id/runners" do
    before do
      visit project_runners_path(@project)
    end

    it { page.should have_content @project.name }
    it { page.should have_content 'How to setup a new project specific runner' }
  end
end
