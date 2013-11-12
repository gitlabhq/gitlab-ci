require 'spec_helper'

describe NotificationService do
  let(:notification) { NotificationService.new }

  describe 'Builds' do
    let(:project) { FactoryGirl.create(:project)}

    describe 'failed build' do
      let(:build) { FactoryGirl.create(:build, :status => :failed, :project => project) }
      it do
        should_email(build.git_author_email)
        notification.build_ended(build)
      end

      def should_email(user_id)
        Notify.should_receive(:build_fail_email).with(build.id)
        Notify.should_not_receive(:build_success_email).with(build.id)
      end
    end

    describe 'successfull build with default settings' do
      before(:each) do
        @settings = double("settings")
        @settings.stub(:only_fail_notifications) { true }
        stub_const("Settings", Class.new)
        Settings.stub_chain(:gitlab_ci).and_return(@settings)
      end

      let(:build) { FactoryGirl.create(:build, :status => :success, :project => project) }
      it do
        should_not_email(build.git_author_email)
        notification.build_ended(build)
      end

      def should_not_email(user_id)
        Notify.should_not_receive(:build_success_email).with(build.id)
        Notify.should_not_receive(:build_fail_email).with(build.id)
      end
    end

    describe 'successfull build with changed settings' do
      before(:each) do
        @settings = double("settings")
        @settings.stub(:only_fail_notifications) { false }
        stub_const("Settings", Class.new)
        Settings.stub_chain(:gitlab_ci).and_return(@settings)
      end

      let(:build) { FactoryGirl.create(:build, :status => :success, :project => project) }
      
      it do
        should_email(build.git_author_email)
        notification.build_ended(build)
      end

      def should_email(user_id)
        Notify.should_receive(:build_success_email).with(build.id)
        Notify.should_not_receive(:build_fail_email).with(build.id)
      end
    end


  end

end
