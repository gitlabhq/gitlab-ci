require 'spec_helper'

describe "Projects" do
  before do
    login_as :user
    @project = FactoryGirl.create :project
  end

  describe "GET /projects", js: true do
    before do
      visit projects_path
    end

    it { page.should have_content @project.name }
  end

  describe "GET /projects/:id" do
    before do
      visit project_path(@project)
    end

    it { page.should have_content @project.name }
    it { page.should have_content 'All builds' }
  end

  describe "GET /projects/:id/edit" do
    before do
      visit edit_project_path(@project)
    end

    it { page.should have_content @project.name }
    it { page.should have_content 'Build Schedule' }
  end

  describe "GET /projects/:id/stats" do
    before do
      visit charts_project_path(@project)
    end

    it { page.should have_content @project.name }
    it { page.should have_content 'Builds chart for last year' }
  end

  describe "GET /projects/:id/details" do
    before do
      visit integration_project_path(@project)
    end

    it { page.should have_content @project.name }
    it { page.should have_content 'Integration with GitLab' }
  end
end
