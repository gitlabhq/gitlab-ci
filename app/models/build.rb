class Build < ActiveRecord::Base
  belongs_to :project

  attr_accessible :project_id, :ref, :sha,
    :status, :finished_at, :trace, :started_at

  validates :sha, presence: true
  validates :ref, presence: true
  validates :status, presence: true

  def failed?
    status == 'fail'
  end

  def success?
    status == 'success'
  end

  def git_author_name
    project.last_commit(self.sha).author.name
  rescue
    nil
  end

  def running?
    status == 'running'
  end

  def success!
    update_status 'success'
  end

  def fail!
    update_status 'fail'
  end

  def running!
    update_status 'running'
  end

  def update_status status
    update_attributes(status: status)
  end

  def write_trace(trace)
    self.reload
    update_attributes(trace: ansi_color_codes(trace))
  end

  def short_sha
    sha[0..8]
  end

  def ansi_color_codes(string)
    string.gsub("\e[0m", '</span>').
      gsub(/\e\[(\d+)m/, "<span class=\"color\\1\">")
  end
end


# == Schema Information
#
# Table name: builds
#
#  id          :integer(4)      not null, primary key
#  project_id  :integer(4)
#  ref         :string(255)
#  status      :string(255)
#  finished_at :datetime
#  trace       :text
#  created_at  :datetime        not null
#  updated_at  :datetime        not null
#  sha         :string(255)
#

