# == Schema Information
#
# Table name: runner_projects
#
#  id         :integer          not null, primary key
#  runner_id  :integer          not null
#  project_id :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class RunnerProject < ActiveRecord::Base
  attr_accessible :project_id, :runner_id

  belongs_to :runner
  belongs_to :project

  validates_uniqueness_of :runner_id, scope: :project_id
end
