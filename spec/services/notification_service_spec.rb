require 'rails_helper'

describe NotificationService do
  let(:notification) { NotificationService.new }

  describe 'Builds' do
    let(:project) { FactoryGirl.create(:project)}
    let(:status) { :success }
    let(:build) { FactoryGirl.create(:build, status: status, project: project) }

    def should_email(email, options = {})
      expect(Notify).to receive(options[:should]).with(build.id, email)
      expect(Notify).not_to receive(:build_success_email).with(build.id, email)
    end
    describe 'failed build' do
      let(:status) { :failed }

      it do
        should_email build.git_author_email, should: :build_fail_email, should_not: :build_success_email
        notification.build_ended(build)
      end

    end

    describe 'successfull build' do
      it do
        should_email build.git_author_email, should: :build_success_email, should_not: :build_fail_email
        notification.build_ended(build)
      end
    end

    describe 'successfull build and project has email_recipients' do
      let(:project) { FactoryGirl.create(:project, :email_recipients => "jeroen@example.com")}

      it do
        should_email build.git_author_email, should: :build_success_email, should_not: :build_fail_email
        should_email "jeroen@example.com", should: :build_success_email, should_not: :build_fail_email
        notification.build_ended(build)
      end
    end
  end
end
