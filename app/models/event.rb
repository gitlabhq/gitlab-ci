class Event < ActiveRecord::Base
  belongs_to :project

  validates :description,
    presence: true,
    length: { in: 5..200 }
end
