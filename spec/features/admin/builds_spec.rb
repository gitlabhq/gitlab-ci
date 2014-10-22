require 'spec_helper'

describe "Admin Builds" do
  let(:project) { FactoryGirl.create :project }
  let(:build) { FactoryGirl.create :build, project: project }

  before do
    skip_admin_auth
    login_as :user
  end

  describe "GET /admin/builds" do
    before do
      build
      visit admin_builds_path
    end

    it { page.should have_content "All builds" }
    it { page.should have_content build.short_sha }
  end
end
