require 'spec_helper'

describe Upgrader do
  let(:upgrader) { Upgrader.new }
  let(:current_version) { GitlabCi::VERSION }

  describe 'current_version_raw' do
    it { upgrader.current_version_raw.should == current_version }
  end

  describe 'latest_version?' do
    it 'should be true if newest version' do
      upgrader.stub(latest_version_raw: current_version)
      upgrader.latest_version?.should be_true
    end
  end

  describe 'latest_version_raw' do
    it 'should be latest version for GitLab' do
      upgrader.stub(current_version_raw: '3.0.0')
      upgrader.stub(git_tags: [
        '1b5bee25b51724214c7a3307ef94027ab93ec982        refs/tags/v7.8.1'])
      upgrader.latest_version_raw.should == 'v7.8.1'
    end
  end
end
