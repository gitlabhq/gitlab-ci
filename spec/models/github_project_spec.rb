require 'spec_helper'

describe GithubProject do
  let(:project) { FactoryGirl.create(:github_project) }
  subject { project }

  it { should be_valid }
end
