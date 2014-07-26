require 'rails_helper'

describe WebHookService do
  let (:project) { FactoryGirl.create :project }
  let (:build) { FactoryGirl.create :build, project: project }
  let (:hook)    { FactoryGirl.create :web_hook, project: project }

  describe :execute do
    it "should execute successfully" do
      stub_request(:post, hook.url).to_return(status: 200)
      expect(WebHookService.new.build_end(build)).to be_truthy
    end
  end

  context 'build_data' do
    it { expect(build_data(build)).to include :build_id, :project_id, :ref, :build_status, :build_started_at, :build_finished_at, :before_sha, :project_name, :gitlab_url }
  end

  def build_data(build)
    WebHookService.new.send :build_data, build
  end
end
