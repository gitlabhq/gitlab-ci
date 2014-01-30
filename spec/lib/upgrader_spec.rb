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
    it 'should be latest version for GitLab 5' do
      upgrader.stub(current_version_raw: "3.0.0")
      upgrader.latest_version_raw.should == "v3.2.0"
    end
  end
end
