require 'rails_helper'

describe ImageForBuildService do
  let(:service) { ImageForBuildService.new }
  let(:project) { FactoryGirl.create(:project) }
  let(:build) { FactoryGirl.create(:build, project: project, ref: 'master') }

  describe :execute do
    before { build }

    context 'branch name' do
      let(:image) { service.execute(project, ref: 'master') }

      it { expect(image).to be_kind_of(OpenStruct) }
      it { expect(image.path.to_s).to include('public/running.png') }
      it { expect(image.name).to eq('running.png') }
    end

    context 'unknown branch name' do
      let(:image) { service.execute(project, ref: 'feature') }

      it { expect(image).to be_kind_of(OpenStruct) }
      it { expect(image.path.to_s).to include('public/unknown.png') }
      it { expect(image.name).to eq('unknown.png') }
    end

    context 'commit sha' do
      let(:image) { service.execute(project, sha: build.sha) }

      it { expect(image).to be_kind_of(OpenStruct) }
      it { expect(image.path.to_s).to include('public/running.png') }
      it { expect(image.name).to eq('running.png') }
    end

    context 'unknown commit sha' do
      let(:image) { service.execute(project, sha: '0000000') }

      it { expect(image).to be_kind_of(OpenStruct) }
      it { expect(image.path.to_s).to include('public/unknown.png') }
      it { expect(image.name).to eq('unknown.png') }
    end
  end
end
