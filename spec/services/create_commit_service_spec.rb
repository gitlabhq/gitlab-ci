require 'spec_helper'

describe CreateCommitService do
  let(:service) { CreateCommitService.new }
  let(:project) { FactoryGirl.create(:project) }

  describe :execute do
    context 'valid params' do
      let(:commit) { service.execute(project, ref: 'refs/heads/master', before: '00000000', after: '31das312') }

      it { commit.should be_kind_of(Commit) }
      it { commit.should be_valid }
      it { commit.should be_persisted }
      it { commit.should == project.commits.last }
      it { commit.builds.first.should be_kind_of(Build) }
    end

    context 'without params' do
      subject { service.execute(project, {}) }

      it { should be_false }
    end

    context "deploy builds" do
      it "calls create_deploy_builds if there are no builds" do
        project.jobs.destroy_all
        Commit.any_instance.should_receive(:create_deploy_builds)
        service.execute(project, ref: 'refs/heads/master', before: '00000000', after: '31das312') 
      end

      it "does not call create_deploy_builds if there is build" do
        Commit.any_instance.should_not_receive(:create_deploy_builds)
        service.execute(project, ref: 'refs/heads/master', before: '00000000', after: '31das312') 
      end
    end
  end
end
