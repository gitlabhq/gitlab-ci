require 'spec_helper'

describe "Lint" do
  before do
    login_as :user
  end

  it "Yaml parsing", js: true do
    content = File.read(Rails.root.join('spec/support/gitlab_stubs/gitlab_ci.yml'))
    visit lint_path 
    fill_in "content", with: content
    click_on "Validate"
    within "table" do
      page.should have_content("Skip Refs")
      page.should have_content("Job - Rspec")
      page.should have_content("Job - Spinach")
      page.should have_content("Deploy Job - cap deploy")
      page.should have_content("Deploy Job - Deploy to staging")
    end
  end

  it "Yaml parsing with error", js: true do
    visit lint_path
    fill_in "content", with: ""
    click_on "Validate"
    page.should have_content("Status: syntax is incorrect")
    page.should have_content("Error: Please provide content of your file")
  end
end
