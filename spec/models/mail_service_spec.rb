require 'spec_helper'

describe MailService do
  describe "Associations" do
    it { should belong_to :project }
  end

  describe "Validations" do
    context "active" do
      before do
        subject.active = true
      end
    end
  end

  describe 'Sends email for' do
    let(:mail)   { MailService.new }

    describe 'failed build' do
      let(:project) { FactoryGirl.create(:project) }
      let(:commit) { FactoryGirl.create(:commit, project: project) }
      let(:build) { FactoryGirl.create(:build, status: :failed, commit: commit) }

      before do
        mail.stub(
          project: project,
          project_id: project.id
        )
      end

      it do
        should_email(commit.git_author_email)
        mail.execute(build)
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

      before do
        mail.stub(
          project: project,
          project_id: project.id
        )
      end

      it do
        should_email(commit.git_author_email)
        mail.execute(build)
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
      let(:recipients) { "jeroen@example.com" }

      before do
        mail.stub(
          project: project,
          project_id: project.id
        )
      end

      it do
        should_email(commit.git_author_email)
        should_email("jeroen@example.com")
        mail.execute(build)
      end

      def should_email(email)
        Notify.should_receive(:build_success_email).with(build.id, email)
        Notify.should_not_receive(:build_fail_email).with(build.id, email)
      end
    end
  end
end
