require 'spec_helper'

describe CreateBuildsService do
  let(:service) { CreateBuildsService.new }
  let(:project) { FactoryGirl.create(:project) }

  describe :execute do
    context 'valid params' do
      let(:builds) { service.execute(project, ref: 'refs/heads/master', before: '00000000', after: '31das312') }
      let(:build) { builds.first }

      it { build.should be_kind_of(Build) }
      it { build.should be_pending }
      it { build.should be_valid }
      it { build.should be_persisted }
      it { build.should == project.last_build }
    end

    context 'without params' do
      let(:builds) { service.execute(project, {}) }
      let(:build) { builds.first }

      it { build.should be_kind_of(Build) }
      it { build.should be_pending }
      it { build.should_not be_valid }
      it { build.should_not be_persisted }
    end
  end
end
