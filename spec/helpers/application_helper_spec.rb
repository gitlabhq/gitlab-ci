require 'spec_helper'

describe ApplicationHelper do
  describe "gravatar_icon" do
    let(:user_email) { 'user@email.com' }

    it "should return a generic avatar path when Gravatar is disabled" do
      GitlabCi.config.gravatar.stub(:enabled).and_return(false)
      gravatar_icon(user_email).should == 'no_avatar.png'
    end

    it "should return a generic avatar path when email is blank" do
      gravatar_icon('').should == 'no_avatar.png'
    end

    context "with no ssl" do
      let!(:request) {
        request_double = double("Request")
        request_double.stub(:ssl?).and_return(false)
        request_double
      }

      it "should return default gravatar url" do
        gravatar_icon(user_email).should match('http://www.gravatar.com/avatar/b58c6f14d292556214bd64909bcdb118')
      end

      it "should return custom gravatar path when gravatar_url is set" do
        GitlabCi.config.gravatar.stub(:plain_url).and_return('http://example.local/?s=%{size}&hash=%{hash}')
        gravatar_icon(user_email, 20).should == 'http://example.local/?s=20&hash=b58c6f14d292556214bd64909bcdb118'
      end

      it "should accept a custom size" do
        gravatar_icon(user_email, 64).should match(/\?s=64/)
      end

      it "should use default size when size is wrong" do
        gravatar_icon(user_email, nil).should match(/\?s=40/)
      end

      it "should be case insensitive" do
        gravatar_icon(user_email).should == gravatar_icon(user_email.upcase + " ")
      end
    end

    context "with ssl" do
      let!(:request) {
        request_double = double("Request")
        request_double.stub(:ssl?).and_return(true)
        request_double
      }

      it "should use SSL when appropriate" do
        gravatar_icon(user_email).should match('https://secure.gravatar.com')
      end
    end
  end

  describe "#duration_in_words" do
    it "returns minutes and seconds" do
      intervals_in_words = {
        100 => "1 minute 40 seconds",
        121 => "2 minutes 1 second",
        3721 => "62 minutes 1 second",
        0 => "0 seconds"
      }

      intervals_in_words.each do |interval, expectation|
        duration_in_words(Time.now + interval, Time.now).should == expectation
      end
    end

    it "calculates interval from now if there is no finished_at" do
      duration_in_words(nil, Time.now - 5).should == "5 seconds"
    end
  end

  describe "#time_interval_in_words" do
    it "returns minutes and seconds" do
      intervals_in_words = {
        100 => "1 minute 40 seconds",
        121 => "2 minutes 1 second",
        3721 => "62 minutes 1 second",
        0 => "0 seconds"
      }

      intervals_in_words.each do |interval, expectation|
        time_interval_in_words(interval).should == expectation
      end
    end
  end
end
