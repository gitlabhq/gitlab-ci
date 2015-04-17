# == Schema Information
#
# Table name: jobs
#
#  id             :integer          not null, primary key
#  project_id     :integer          not null
#  commands       :text
#  active         :boolean          default(TRUE), not null
#  created_at     :datetime
#  updated_at     :datetime
#  name           :string(255)
#  build_branches :boolean          default(TRUE), not null
#  build_tags     :boolean          default(FALSE), not null
#  job_type       :string(255)      default("parallel")
#  refs           :string(255)
#  deleted_at     :datetime
#

require 'spec_helper'

describe Job do
  let(:project) { FactoryGirl.create :project }

  it { should belong_to(:project) }
  it { should have_many(:builds) }

  describe "run_for_ref?" do
    it "allows run for any ref if refs params is empty" do
      job = FactoryGirl.create :job, project: project
      job.run_for_ref?("anything").should be_true
    end

    it "allows run for any ref in refs params" do
      job = FactoryGirl.create :job, project: project, refs: "master, staging, tags/testing*"
      job.run_for_ref?("master").should be_true
      job.run_for_ref?("staging").should be_true
      job.run_for_ref?("testing").should be_false
      job.run_for_ref?("tags/testing").should be_true
      job.run_for_ref?("tags/testing-v0.1.0").should be_true
      job.run_for_ref?("tags/unstable-v0.1.0").should be_false
      job.run_for_ref?("feature/feature-one").should be_false
      job.run_for_ref?("anything").should be_false
    end
  end
end
