require 'rails_helper'

describe "Projects" do
  before do
    login_as :user
    @project = FactoryGirl.create :project
  end

  describe "GET /projects", js: true do
    before do
      stub_js_gitlab_calls
      visit projects_path
    end

    it { expect(page).to have_content @project.name }
  end

  describe "GET /projects/:id" do
    before do
      visit project_path(@project)
    end

    it { expect(page).to have_content @project.name }
    it { expect(page).to have_content 'All builds' }
  end

  describe "GET /projects/:id/edit" do
    before do
      visit edit_project_path(@project)
    end

    it { expect(page).to have_content @project.name }
    it { expect(page).to have_content 'Build Schedule' }
  end

  describe "GET /projects/:id/charts" do
    before do
      visit project_charts_path(@project)
    end

    it { expect(page).to have_content 'Overall' }
    it { expect(page).to have_content 'Builds chart for last week' }
    it { expect(page).to have_content 'Builds chart for last month' }
    it { expect(page).to have_content 'Builds chart for last year' }
    it { expect(page).to have_content 'Build duration in minutes for last 30 builds' }
  end

  describe "GET /projects/:id/details" do
    before do
      visit integration_project_path(@project)
    end

    it { expect(page).to have_content @project.name }
    it { expect(page).to have_content 'Integration with GitLab' }
  end
end
