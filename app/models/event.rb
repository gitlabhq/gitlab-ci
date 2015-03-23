# == Schema Information
#
# Table name: events
#
#  id          :integer          not null, primary key
#  project_id  :integer
#  user_id     :integer
#  is_admin    :integer
#  description :text
#  created_at  :datetime
#  updated_at  :datetime
#

class Event < ActiveRecord::Base
  belongs_to :project

  validates :description,
    presence: true,
    length: { in: 5..200 }

  scope :admin, ->(){ where(is_admin: true) }
  scope :project_wide, ->(){ where(is_admin: false) }
end
