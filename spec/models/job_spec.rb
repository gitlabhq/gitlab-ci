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
      job = FactoryGirl.create :job, project: project, refs: "master, staging"
      job.run_for_ref?("master").should be_true
      job.run_for_ref?("staging").should be_true
      job.run_for_ref?("anything").should be_false
    end
  end
end
