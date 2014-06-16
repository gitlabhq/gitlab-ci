require 'spec_helper'

describe SlackNotificationService do
  let(:notification) { SlackNotificationService.new }

  describe 'Builds' do

    describe 'failed build' do
      let(:project) { FactoryGirl.create(:project,
                                    slack_notification_channel: '#devs',
                                    slack_notification_subdomain: 'example.com',
                                    slack_notification_token: '121212121aaaa',
                                    slack_notification_username: 'gitlab'
        )}
      let(:build) { FactoryGirl.create(:build, :status => :failed, :project => project) }

      it do
        should_slack
        notification.build_ended(build)
      end

      def should_slack
        Slack::Notifier.should_receive(:build_fail_slack_post).with(build)
        Slack::Notifier.should_not_receive(:build_success_slack_post).with(build.id)
      end
    end

    describe 'successfull build' do
      let(:project) { FactoryGirl.create(:project,
                                    slack_notification_channel: '#devs',
                                    slack_notification_subdomain: 'example.com',
                                    slack_notification_token: '121212121aaaa',
                                    slack_notification_username: 'gitlab'
        )}
      let(:build) { FactoryGirl.create(:build, :status => :success, :project => project) }
      it do
        should_slack
        notification.build_ended(build)
      end

      def should_slack
        Slack::Notifier.should_receive(:build_success_slack_post).with(build)
        Slack::Notifier.should_not_receive(:build_fail_slack_post).with(build)
      end
    end

  end
end
