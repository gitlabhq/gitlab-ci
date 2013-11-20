require 'spec_helper'

describe NotificationService do
  let(:notification) { NotificationService.new }

  describe 'Builds' do

    describe 'failed build' do
      let(:project) { FactoryGirl.create(:project, :email_only_breaking_build => true)}
      let(:build) { FactoryGirl.create(:build, :status => :failed, :project => project) }

      it do
        should_email(build.git_author_email)
        notification.build_ended(build)
      end

      def should_email(email)
        Notify.should_receive(:build_fail_email).with(build.id, email)
        Notify.should_not_receive(:build_success_email).with(build.id, email)
      end
    end

    describe 'successfull build when only breaking builds should trigger email' do
      let(:project) { FactoryGirl.create(:project, :email_only_breaking_build => true)}
      let(:build) { FactoryGirl.create(:build, :status => :success, :project => project) }
      it do
        should_not_email(build.git_author_email)
        notification.build_ended(build)
      end

      def should_not_email(email)
        Notify.should_not_receive(:build_success_email).with(build.id, email)
        Notify.should_not_receive(:build_fail_email).with(build.id, email)
      end
    end

    describe 'successfull build when all builds should trigger email' do
      let(:project) { FactoryGirl.create(:project, :email_only_breaking_build => false)}
      let(:build) { FactoryGirl.create(:build, :status => :success, :project => project) }
      
      it do
        should_email(build.git_author_email)
        notification.build_ended(build)
      end

      def should_email(email)
        Notify.should_receive(:build_success_email).with(build.id, email)
        Notify.should_not_receive(:build_fail_email).with(build.id, email)
      end
    end


  end

end
