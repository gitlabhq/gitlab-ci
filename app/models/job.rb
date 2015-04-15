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
#  job_type       :string(255)      default("parallel")
#  refs           :string(255)
#

class Job < ActiveRecord::Base
  acts_as_paranoid
  
  belongs_to :project
  has_many :builds

  acts_as_taggable

  scope :active, ->() { where(active: true) }
  scope :archived, ->() { where(active: false) }
  scope :parallel, ->(){ where(job_type: "parallel") }
  scope :deploy, ->(){ where(job_type: "deploy") }

  validate :refs, length: { maximum: 255 }

  def deploy?
    job_type == "deploy"
  end

  def run_for_ref?(ref)
    if refs.present?
      refs.split(",").map(&:strip).each do |refs_val|
        return true if File.fnmatch(refs_val, ref)
      end

      false
    else
      true
    end
  end
end
