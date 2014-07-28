require 'rails_helper'

describe ApplicationHelper do
  describe "gravatar_icon" do
    let(:user_email) { 'user@email.com' }

    it "should return a generic avatar path when Gravatar is disabled" do
      allow(GitlabCi.config.gravatar).to receive(:enabled).and_return(false)
      expect(gravatar_icon(user_email)).to eq('no_avatar.png')
    end

    it "should return a generic avatar path when email is blank" do
      expect(gravatar_icon('')).to eq('no_avatar.png')
    end

    context "with no ssl" do
      let!(:request) {
        request_double = double("Request")
        allow(request_double).to receive(:ssl?).and_return(false)
        request_double
      }

      it "should return default gravatar url" do
        expect(gravatar_icon(user_email)).to match('http://www.gravatar.com/avatar/b58c6f14d292556214bd64909bcdb118')
      end

      it "should return custom gravatar path when gravatar_url is set" do
        allow(GitlabCi.config.gravatar).to receive(:plain_url).and_return('http://example.local/?s=%{size}&hash=%{hash}')
        expect(gravatar_icon(user_email, 20)).to eq('http://example.local/?s=20&hash=b58c6f14d292556214bd64909bcdb118')
      end

      it "should accept a custom size" do
        expect(gravatar_icon(user_email, 64)).to match(/\?s=64/)
      end

      it "should use default size when size is wrong" do
        expect(gravatar_icon(user_email, nil)).to match(/\?s=40/)
      end

      it "should be case insensitive" do
        expect(gravatar_icon(user_email)).to eq(gravatar_icon(user_email.upcase + " "))
      end
    end

    context "with ssl" do
      let!(:request) {
        request_double = double("Request")
        allow(request_double).to receive(:ssl?).and_return(true)
        request_double
      }

      it "should use SSL when appropriate" do
        expect(gravatar_icon(user_email)).to match('https://secure.gravatar.com')
      end
    end
  end
end
