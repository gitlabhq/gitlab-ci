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

  has_one :last_build, class_name: 'Build'

  attr_accessible :token, :public_key, :description

  before_validation :set_default_values

  def set_default_values
    self.token = SecureRandom.hex(15) if self.token.blank?
  end

  def assign_to(project, current_user)
    ActiveRecord::Base.transaction do
      runner_project = project.runner_projects.create!(runner_id: self.id)

      opts = {
        key: self.public_key,
        title: "gitlab-ci-runner-#{self.id}",
        private_token: current_user.private_token
      }

      result = Network.new.add_deploy_key(current_user.url, project.gitlab_id, opts)
      raise "Can't add deploy key" unless result
      true
    end
  rescue => ex
    logger.warn "Assign runner to project failed: #{ex}"
    false
  end

  def display_name
    return token unless !description.blank?

    description
  end
end
