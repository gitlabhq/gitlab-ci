require 'spec_helper'

describe Build do
  subject { Build.new }

  it { should belong_to(:project) }
  it { should validate_presence_of :sha }
  it { should validate_presence_of :ref }
  it { should validate_presence_of :status }
end


# == Schema Information
#
# Table name: builds
#
#  id          :integer(4)      not null, primary key
#  project_id  :integer(4)
#  ref         :string(255)
#  status      :string(255)
#  finished_at :datetime
#  trace       :text
#  created_at  :datetime        not null
#  updated_at  :datetime        not null
#  sha         :string(255)
#

