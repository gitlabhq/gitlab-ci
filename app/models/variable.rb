# == Schema Information
#
# Table name: variables
#
#  id         :integer          not null, primary key
#  project_id :integer          not null
#  key        :string(255)
#  value      :text
#

class Variable < ActiveRecord::Base
  belongs_to :project
end
