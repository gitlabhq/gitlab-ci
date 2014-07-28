require 'rails_helper'

describe Upgrader do
  let(:upgrader) { Upgrader.new }
  let(:current_version) { GitlabCi::VERSION }

  describe 'current_version_raw' do
    it { expect(upgrader.current_version_raw).to eq(current_version) }
  end

  describe 'latest_version?' do
    it 'should be true if newest version' do
      allow(upgrader).to receive(:latest_version_raw) { current_version }
      expect(upgrader.latest_version?).to be_truthy
    end
  end

  describe 'latest_version_raw' do
    it 'should be latest version for GitLab 5' do
      allow(upgrader).to receive(:current_version_raw) { "3.0.0" }
      expect(upgrader.latest_version_raw).to eq("v3.2.0")
    end
  end
end
