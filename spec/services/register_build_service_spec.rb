require 'spec_helper'

describe RegisterBuildService do
  let!(:service) { RegisterBuildService.new }
  let!(:project) { FactoryGirl.create :project }
  let!(:job) { FactoryGirl.create :job, project: project }
  let!(:commit) { FactoryGirl.create :commit, project: project }
  let!(:pending_build) { commit.create_build_from_job(job) }
  let!(:shared_runner) { FactoryGirl.create(:runner, is_shared: true) }
  let!(:specific_runner) { FactoryGirl.create(:runner, is_shared: false) }

  before do
    specific_runner.assign_to(project)
  end

  describe :execute do
    context 'allow shared runners' do
      before do
        project.shared_runners_enabled = true
        project.save
      end

      context 'shared runner' do
        let(:build) { service.execute(shared_runner) }

        it { build.should be_kind_of(Build) }
        it { build.should be_valid }
        it { build.should be_running }
        it { build.runner.should == shared_runner }
      end

      context 'specific runner' do
        let(:build) { service.execute(specific_runner) }

        it { build.should be_kind_of(Build) }
        it { build.should be_valid }
        it { build.should be_running }
        it { build.runner.should == specific_runner }
      end
    end

    context 'disallow shared runners' do
      context 'shared runner' do
        let(:build) { service.execute(shared_runner) }

        it { build.should be_nil }
      end

      context 'specific runner' do
        let(:build) { service.execute(specific_runner) }

        it { build.should be_kind_of(Build) }
        it { build.should be_valid }
        it { build.should be_running }
        it { build.runner.should == specific_runner }
      end
    end
  end
end
