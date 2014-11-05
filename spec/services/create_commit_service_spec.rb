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
      let(:commit) { service.execute(project, {}) }

      it { commit.should be_kind_of(Commit) }
      it { commit.should_not be_valid }
      it { commit.should_not be_persisted }
    end
  end
end
