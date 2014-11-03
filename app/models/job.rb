class Job < ActiveRecord::Base
  belongs_to :project

  scope :active, ->() { where(active: true) }
  scope :archived, ->() { where(active: false) }
end
