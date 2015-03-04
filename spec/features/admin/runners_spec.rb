require 'spec_helper'

describe "Admin Runners" do
  before do
    skip_admin_auth
    login_as :user
  end

  describe "GET /admin/runners" do
    before do
      runner = FactoryGirl.create(:runner)
      commit = FactoryGirl.create(:commit)
      FactoryGirl.create(:build, commit: commit, runner_id: runner.id)
      visit admin_runners_path
    end

    it { page.has_text? "Manage Runners" }
    it { page.has_text? "To register a new runner" }
  end

  describe "GET /admin/runners/:id" do
    let(:runner) { FactoryGirl.create :runner }

    before do
      visit admin_runner_path(runner)
    end

    it { find_field('runner_token').value.should eq runner.token }
  end
end
