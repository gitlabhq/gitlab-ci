require 'spec_helper'

describe "Projects" do
  before do
    login_as :user

    opts = {
      id: 1,
      name: 'GitLab',
      status: nil,
      last_build: nil
    }

    @project = Project.new
    @project.stub(opts)

  end

  describe "GET /projects" do
    before do
      Project.stub(all: [@project])
      visit projects_path
    end

    it { page.should have_content @project.name }
    it { page.should have_content 'Add Project' }
  end

  describe "GET /projects/:id" do
    before do
      Project.stub(find: @project)
      visit project_path(@project)
    end

    it { page.should have_content @project.name }
  end
end

