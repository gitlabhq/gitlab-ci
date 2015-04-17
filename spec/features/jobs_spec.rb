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
      it "updates job" do
        fill_in 'Script', with: 'pwd'
        fill_in 'Name', with: 'New Job'
        fill_in 'Tags', with: 'Tags'
        check "Builds commits"
        check "Build tags"

        click_button 'Save changes'

        page.should have_content 'successfully updated'

        find_field('Script').value.should eq 'pwd'
        find_field('Name').value.should eq 'New Job'
        find_field('Tags').value.should eq 'Tags'
        find_field('Builds commits').should be_checked
        find_field('Build tags').should be_checked
      end
    end
  end

  describe "GET /projects/:id/jobs/deploy_jobs" do
    before do
      visit deploy_jobs_project_jobs_path(@project)
    end

    it { page.should have_content @project.name } 
    it { page.should have_link 'Add a job' }
    it { page.should have_content 'Deploy jobs are scripts you want CI to run on succeeding all parallel builds' }

    describe 'change job script', js: true do
      it "updates deploy job" do
        click_on "Add a job"

        fill_in 'Script', with: 'pwd'
        fill_in 'Name', with: 'New Job'
        fill_in 'Tags', with: 'Tags'
        fill_in 'Refs', with: 'master'

        click_button 'Save changes'

        page.should have_content 'successfully updated'

        find_field('Script').value.should eq 'pwd'
        find_field('Name').value.should eq 'New Job'
        find_field('Tags').value.should eq 'Tags'
        find_field('Refs').value.should eq 'master'
      end
    end
  end
end
