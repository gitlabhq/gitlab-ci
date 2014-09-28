# == Schema Information
#
# Table name: web_hooks
#
#  id         :integer          not null, primary key
#  url        :string(255)      not null
#  project_id :integer          not null
#  created_at :datetime
#  updated_at :datetime
#

require 'rails_helper'

describe WebHook do
  describe "Associations" do
    it { should belong_to :project }
  end

  describe "Mass assignment" do
    it { should_not allow_mass_assignment_of(:project_id) }
  end

  describe "Validations" do
    it { should validate_presence_of(:url) }

    context "url format" do
      it { should allow_value("http://example.com").for(:url) }
      it { should allow_value("https://excample.com").for(:url) }
      it { should allow_value("http://test.com/api").for(:url) }
      it { should allow_value("http://test.com/api?key=abc").for(:url) }
      it { should allow_value("http://test.com/api?key=abc&type=def").for(:url) }

      it { should_not allow_value("example.com").for(:url) }
      it { should_not allow_value("ftp://example.com").for(:url) }
      it { should_not allow_value("herp-and-derp").for(:url) }
    end
  end

  describe "execute" do
    before(:each) do
      @web_hook = FactoryGirl.create(:web_hook)
      @project = @web_hook.project
      @data = { before: 'oldrev', after: 'newrev', ref: 'ref'}

      WebMock.stub_request(:post, @web_hook.url)
    end

    it "POSTs to the web hook URL" do
      @web_hook.execute(@data)
      expect(WebMock).to have_requested(:post, @web_hook.url).once
    end

    it "POSTs the data as JSON" do
      json = @data.to_json

      @web_hook.execute(@data)
      expect(WebMock).to have_requested(:post, @web_hook.url).with(body: json).once
    end

    it "catches exceptions" do
      expect(WebHook).to receive(:post).and_raise("Some HTTP Post error")

      expect { @web_hook.execute(@data) }.to raise_error
    end
  end
end
