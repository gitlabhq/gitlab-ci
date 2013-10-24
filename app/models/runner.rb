# == Schema Information
#
# Table name: runners
#
#  id          :integer          not null, primary key
#  token       :string(255)
#  public_key  :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  description :string(255)
#

class Runner < ActiveRecord::Base
  has_many :builds
  has_many :runner_projects, dependent: :destroy
  has_many :projects, through: :runner_projects

  has_one :last_build, class_name: 'Build', order: 'id DESC'

  attr_accessible :token, :public_key, :description

  before_validation :set_default_values

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
end
