require 'spec_helper'

describe RegisterBuildService do
  let!(:service) { RegisterBuildService.new }
  let!(:project) { FactoryGirl.create :project }
  let!(:job)     { FactoryGirl.create :job, project: project }
  let!(:commit)  { FactoryGirl.create :commit, project: project }
  let!(:pending_build)   { commit.create_build_from_job(job) }

  describe :execute do
    describe 'shared runner' do
      let(:runner) { FactoryGirl.create(:runner, is_shared: true) }

      context 'allow shared runners' do
        before do
          project.shared_runners_enabled = true
          project.save
        end

        let(:build) { service.execute(runner) }

        it { build.should be_kind_of(Build) }
        it { build.should be_valid }
        it { build.should be_running }
        it { build.runner.should == runner }
      end

      context 'disallow shared runners' do
        let(:build) { service.execute(runner) }

        it { build.should be_nil }
      end
    end
  end
end
