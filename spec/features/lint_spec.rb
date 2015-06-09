require 'spec_helper'

describe "Lint" do
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
  
end
