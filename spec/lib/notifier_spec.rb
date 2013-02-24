require 'spec_helper'

describe 'Notifier' do
  let(:user) { FactoryGirl.create :github_user }
  let(:github_project) { FactoryGirl.create(:github_project) }
  let(:build) { FactoryGirl.create(:build, project:github_project) }

  context "(github commit status)" do
    let(:notifier) { Notifier.new }

    context "when build successed" do
      it "post success message" do
        notifier.should_receive(:post_status_to_github)
                .with("success", anything(), /successed/)
        notifier.perform build.id, "success"
      end
    end

    context "when build failed" do
      it "post failed state" do
        notifier.should_receive(:post_status_to_github)
                .with("failure", anything(), /failed/)
        notifier.perform build.id, "failed"
      end
    end

    context "when build canceled" do
      it "post failed state" do
        notifier.should_receive(:post_status_to_github)
                .with("failure", anything(), /failed/)
        notifier.perform build.id, "canceled"
      end
    end
  end
end

