require 'spec_helper'

describe "Admin Projects" do
  before do
    skip_admin_auth
    login_as :user
  end

  describe "GET /admin/projects" do
    before do
      visit admin_projects_path
    end

    it { page.should have_content "Admin / Projects" }
  end
end

