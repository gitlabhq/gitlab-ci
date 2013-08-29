# == Schema Information
#
# Table name: runners
#
#  id          :integer          not null, primary key
#  token       :string(255)
#  public_key  :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
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
end
