
require 'spec_helper'

describe Trigger do
  let(:project) { FactoryGirl.create :project }

  subject { FactoryGirl.create :trigger, project: project }

  describe 'before_validation' do
    it 'should set an random token if none provided' do
      project = FactoryGirl.create :trigger_without_token
      project.token.should_not == ""
    end

    it 'should not set an random token if one provided' do
      project = FactoryGirl.create :trigger
      project.token.should == 'token'
    end
  end
end
