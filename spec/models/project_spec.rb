require 'spec_helper'

describe Project do
  subject { FactoryGirl.build :project }

  it { should have_many(:builds) }

  describe :path do
    it { should allow_value(Rails.root.join('tmp', 'test_repo')).for(:path) }
    it { should_not allow_value('/tmp').for(:path) }
  end

  it { should validate_presence_of :name }
  it { should validate_presence_of :scripts }
  it { should validate_presence_of :timeout }
  it { should validate_presence_of :token }
  it { should validate_presence_of :default_ref }
end

# == Schema Information
#
# Table name: projects
#
#  id          :integer(4)      not null, primary key
#  name        :string(255)     not null
#  path        :string(255)     not null
#  timeout     :integer(4)      default(1800), not null
#  scripts     :text            default(""), not null
#  created_at  :datetime        not null
#  updated_at  :datetime        not null
#  token       :string(255)
#  default_ref :string(255)
#

