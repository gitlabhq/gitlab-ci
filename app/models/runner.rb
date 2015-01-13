# == Schema Information
#
# Table name: runners
#
#  id          :integer          not null, primary key
#  token       :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#  description :string(255)
#

class Runner < ActiveRecord::Base
  has_many :builds
  has_many :runner_projects, dependent: :destroy
  has_many :projects, through: :runner_projects

  has_one :last_build, ->() { order('id DESC') }, class_name: 'Build'

  attr_accessible :token, :description

  before_validation :set_default_values

  scope :specific, ->() { where(id: RunnerProject.select(:runner_id)) }
  scope :shared, ->() { where.not(id: RunnerProject.select(:runner_id)) }

  def set_default_values
    self.token = SecureRandom.hex(15) if self.token.blank?
  end

  def assign_to(project, current_user)
    project.runner_projects.create!(runner_id: self.id)
  end

  def display_name
    return token unless !description.blank?

    description
  end

  def shared?
    runner_projects.blank?
  end

  def only_for?(project)
    projects == [project]
  end

  def short_sha
    token[0...10]
  end
end
