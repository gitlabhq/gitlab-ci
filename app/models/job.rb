# == Schema Information
#
# Table name: jobs
#
#  id             :integer          not null, primary key
#  project_id     :integer          not null
#  commands       :text
#  active         :boolean          default(TRUE), not null
#  created_at     :datetime
#  updated_at     :datetime
#  name           :string(255)
#  build_branches :boolean          default(TRUE), not null
#  build_tags     :boolean          default(FALSE), not null
#

class Job < ActiveRecord::Base
  belongs_to :project
  has_many :builds

  scope :active, ->() { where(active: true) }
  scope :archived, ->() { where(active: false) }
end
