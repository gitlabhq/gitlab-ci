require 'spec_helper'

describe ImageForBuildService do
  let(:service) { ImageForBuildService.new }
  let(:project) { FactoryGirl.create(:project) }
  let(:commit) { FactoryGirl.create(:commit, project: project, ref: 'master') }
  let(:build) { FactoryGirl.create(:build, commit: commit) }

  describe :execute do
    before { build }

    context 'branch name' do
      before { build.run! }
      let(:image) { service.execute(project, ref: 'master') }

      it { image.should be_kind_of(OpenStruct) }
      it { image.path.to_s.should include('public/running.png') }
      it { image.name.should == 'running.png' }
    end

    context 'unknown branch name' do
      let(:image) { service.execute(project, ref: 'feature') }

      it { image.should be_kind_of(OpenStruct) }
      it { image.path.to_s.should include('public/unknown.png') }
      it { image.name.should == 'unknown.png' }
    end

    context 'commit sha' do
      before { build.run! }
      let(:image) { service.execute(project, sha: build.sha) }

      it { image.should be_kind_of(OpenStruct) }
      it { image.path.to_s.should include('public/running.png') }
      it { image.name.should == 'running.png' }
    end

    context 'unknown commit sha' do
      let(:image) { service.execute(project, sha: '0000000') }

      it { image.should be_kind_of(OpenStruct) }
      it { image.path.to_s.should include('public/unknown.png') }
      it { image.name.should == 'unknown.png' }
    end
  end
end
