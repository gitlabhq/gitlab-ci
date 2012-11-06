require 'spec_helper'

describe "Projects" do
  before do
    login_as :user
    @project = FactoryGirl.create :project
  end

  describe "GET /projects" do
    before do
      visit projects_path
    end

    it { page.should have_content @project.name }
    it { page.should have_content 'Add Project' }
  end

  describe "GET /projects/:id" do
    before do
      visit project_path(@project)
    end

    it { page.should have_content @project.name }
  end
end

