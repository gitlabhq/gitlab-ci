require 'rails_helper'

describe CreateBuildService do
  let(:service) { CreateBuildService.new }
  let(:project) { FactoryGirl.create(:project) }

  describe :execute do
    context 'valid params' do
      let(:build) { service.execute(project, ref: 'refs/heads/master', before: '00000000', after: '31das312') }

      it { expect(build).to be_kind_of(Build) }
      it { expect(build).to be_pending }
      it { expect(build).to be_valid }
      it { expect(build).to be_persisted }
      it { expect(build).to eq(project.last_build) }
    end

    context 'without params' do
      let(:build) { service.execute(project, {}) }

      it { expect(build).to be_kind_of(Build) }
      it { expect(build).to be_pending }
      it { expect(build).not_to be_valid }
      it { expect(build).not_to be_persisted }
    end
  end
end
