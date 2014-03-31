require 'spec_helper'

describe CreateBuildService do
  let(:service) { CreateBuildService.new }
  let(:project) { FactoryGirl.create(:project) }

  describe :execute do
    context 'valid params' do
      let(:build) { service.execute(project, ref: 'refs/heads/master', before: '00000000', after: '31das312') }

      it { build.should be_kind_of(Build) }
      it { build.should be_pending }
      it { build.should be_valid }
      it { build.should be_persisted }
      it { build.should == project.last_build }
    end

    context 'without params' do
      let(:build) { service.execute(project, {}) }

      it { build.should be_kind_of(Build) }
      it { build.should be_pending }
      it { build.should_not be_valid }
      it { build.should_not be_persisted }
    end
  end
end
