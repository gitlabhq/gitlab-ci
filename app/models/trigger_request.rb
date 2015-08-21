# == Schema Information
#
# Table name: trigger_requests
#
#  id         :integer          not null, primary key
#  trigger_id :integer          not null
#  variables  :text
#  created_at :datetime
#  updated_at :datetime
#  commit_id  :integer
#

class TriggerRequest < ActiveRecord::Base
  belongs_to :trigger
  belongs_to :commit
  has_many :builds

  serialize :variables
end
