require 'spec_helper'

describe Travis do
  subject { Travis::Config.new(Rails.root.join("spec/fixtures/travis.yml")) }

  it "should parse scripts" do
    subject.scripts.should == ["mysql -e 'create database myapp_test'", "psql -c 'create database myapp_test' -U postgres", "RAILS_ENV=test bundle exec rake --trace db:migrate test"]
  end

  it "should parse env" do
    subject.env.should == 'DB=sqlite'
  end

  its(:to_runnable){ should be }
end
