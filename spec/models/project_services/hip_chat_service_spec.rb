
require 'spec_helper'

describe HipChatService do

  describe "Validations" do

    context "active" do
      before do
        subject.active = true
      end

      it { should validate_presence_of :hipchat_room }
      it { should validate_presence_of :hipchat_token }

    end
  end

  describe "Execute" do

    let(:service) { HipChatService.new }
    let(:project) { FactoryGirl.create :project }
    let(:commit)  { FactoryGirl.create :commit, project: project }
    let(:build)   { FactoryGirl.create :build, commit: commit, status: 'failed' }
    let(:api_url) { 'https://api.hipchat.com/v2/room/123/notification?auth_token=a1b2c3d4e5f6' }

    before do
      service.stub(
        project: project,
        project_id: project.id,
        notify_only_broken_builds: false,
        hipchat_room: 123,
        hipchat_token: 'a1b2c3d4e5f6'
      )

      WebMock.stub_request(:post, api_url)
    end


    it "should call the HipChat API" do
      service.execute(build)
      HipChatNotifierWorker.drain

      WebMock.should have_requested(:post, api_url).once
    end
  end
end

