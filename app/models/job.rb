class Job < ActiveRecord::Base
  belongs_to :project
  has_many :builds

  scope :active, ->() { where(active: true) }
  scope :archived, ->() { where(active: false) }
end
