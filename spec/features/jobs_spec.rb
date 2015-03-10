require 'spec_helper'

describe "Jobs" do
  before do
    login_as :user
    @project = FactoryGirl.create :project
  end

  describe "GET /projects/:id/jobs" do
    before do
      visit project_jobs_path(@project)
    end

    it { page.should have_content @project.name }
    it { page.should have_link 'Add a job' }

    describe 'change job script' do
      before do
        fill_in 'project_jobs_attributes_0_commands', with: 'Wow'
        click_button 'Save changes'
      end

      it { page.should have_content 'successfully updated'}
    end
  end

  describe "GET /projects/:id/jobs/deploy_jobs" do
    before do
      visit deploy_jobs_project_jobs_path(@project)
    end

    it { page.should have_content @project.name } 
    it { page.should have_link 'Add a job' }
    it { page.should have_content 'Deploy jobs are scripts you want CI to run on succeeding all parallel builds' }
  end
end
