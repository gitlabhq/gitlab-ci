class Event < ActiveRecord::Base
  belongs_to :project

  validates :description,
    presence: true,
    length: { in: 5..200 }

  scope :admin, ->(){ where(is_admin: true) }
  scope :project_wide, ->(){ where(is_admin: false) }
end
