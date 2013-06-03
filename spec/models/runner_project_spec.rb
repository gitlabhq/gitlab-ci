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

require 'spec_helper'

describe RunnerProject do
  pending "add some examples to (or delete) #{__FILE__}"
end
