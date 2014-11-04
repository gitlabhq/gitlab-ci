require 'spec_helper'

describe "Admin Projects" do
  let(:project) { FactoryGirl.create :project }

  before do
    skip_admin_auth
    login_as :user
  end

  describe "GET /admin/projects" do
    before do
      visit admin_projects_path
    end

    it { page.should have_content "Manage Projects" }
  end

  describe "GET /admin/projects/:id" do
    before do
      visit admin_project_path(project)
    end

    it { page.should have_content "Project info" }
    it { page.should have_content project.name }
  end
end
