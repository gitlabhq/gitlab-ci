require 'spec_helper'

describe NotificationService do
  let(:notification) { NotificationService.new }

  describe 'Builds' do

    describe 'failed build' do
      let(:project) { FactoryGirl.create(:project) }
      let(:commit) { FactoryGirl.create(:commit, project: project) }
      let(:build) { FactoryGirl.create(:build, status: :failed, commit: commit) }

      it do
        should_email(commit.git_author_email)
        notification.build_ended(build)
      end

      def should_email(email)
        Notify.should_receive(:build_fail_email).with(build.id, email)
        Notify.should_not_receive(:build_success_email).with(build.id, email)
      end
    end

    describe 'successfull build' do
      let(:project) { FactoryGirl.create(:project) }
      let(:commit) { FactoryGirl.create(:commit, project: project) }
      let(:build) { FactoryGirl.create(:build, status: :success, commit: commit) }
      it do
        should_email(commit.git_author_email)
        notification.build_ended(build)
      end

      def should_email(email)
        Notify.should_receive(:build_success_email).with(build.id, email)
        Notify.should_not_receive(:build_fail_email).with(build.id, email)
      end
    end

    describe 'successfull build and project has email_recipients' do
      let(:project) { FactoryGirl.create(:project, email_recipients: "jeroen@example.com") }
      let(:commit) { FactoryGirl.create(:commit, project: project) }
      let(:build) { FactoryGirl.create(:build, status: :success, commit: commit) }

      it do
        should_email(commit.git_author_email)
        should_email("jeroen@example.com")
        notification.build_ended(build)
      end

      def should_email(email)
        Notify.should_receive(:build_success_email).with(build.id, email)
        Notify.should_not_receive(:build_fail_email).with(build.id, email)
      end
    end
  end
end
