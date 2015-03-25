# == Schema Information
#
# Table name: runners
#
#  id          :integer          not null, primary key
#  token       :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#  description :string(255)
#

require 'spec_helper'

describe Runner do
  describe '#display_name' do
    it 'should return the description if it has a value' do
      runner = FactoryGirl.build(:runner, description: 'Linux/Ruby-1.9.3-p448')
      expect(runner.display_name).to eq 'Linux/Ruby-1.9.3-p448'
    end

    it 'should return the token if it does not have a description' do
      runner = FactoryGirl.build(:runner)
      expect(runner.display_name).to eq runner.token
    end

    it 'should return the token if the description is an empty string' do
      runner = FactoryGirl.build(:runner, description: '')
      expect(runner.display_name).to eq runner.token
    end
  end

  describe :assign_to do
    let!(:project) { FactoryGirl.create :project }
    let!(:shared_runner) { FactoryGirl.create(:runner, is_shared: true) }

    before { shared_runner.assign_to(project) }

    it { shared_runner.should be_specific }
    it { shared_runner.projects.should == [project] }
    it { shared_runner.only_for?(project).should be_true }
  end
end
