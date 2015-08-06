# == Schema Information
#
# Table name: triggers
#
#  id         :integer          not null, primary key
#  token      :string(255)
#  project_id :integer          not null
#  deleted_at :datetime
#  created_at :datetime
#  updated_at :datetime
#

class Trigger < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :project
  has_many :trigger_requests, dependent: :destroy

  validates_presence_of :token
  validates_uniqueness_of :token

  before_validation :set_default_values

  def set_default_values
    self.token = SecureRandom.hex(15) if self.token.blank?
  end

  def last_trigger_request
    trigger_requests.last
  end

  def short_token
    token[0...10]
  end
end
