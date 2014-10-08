class BuildGroup < ActiveRecord::Base
  belongs_to :project

  serialize :push_data

  attr_accessible :project_id, :ref, :ref_type, :sha, :before_sha,
                  :started_at, :push_data

  validates :before_sha, presence: true
  validates :sha, presence: true
  validates :ref, presence: true
  validates :ref_type, presence: true

  has_many :builds, dependent: :destroy

  scope :heads, ->() { where(ref_type: "heads") }
  scope :tags, ->() { where(ref_type: "tags") }

  def valid_commit_sha
    if self.sha =~ /\A00000000/
      self.errors.add(:sha, " cant be 00000000 (branch removal)")
    end
  end

  def statuses
    Hash[builds.select(:status).distinct.map { |a| [a.status.to_sym, true] }]
  end

  def status
    h = statuses
    if h[:running]
      :running
    elsif h[:pending]
      if h[:failed] || h[:success] || h[:canceled]
        :running
      else
        :pending
      end
    elsif h[:failed]
      :failed
    elsif h[:canceled]
      :canceled
    elsif h[:success]
      :success
    else
      :success
    end
  end

  def one?
    builds.count == 1
  end

  def head?
    ref_type == 'heads'
  end

  def tag?
    ref_type == 'tags'
  end

  def pending?
    status == :pending
  end

  def running?
    status == :running
  end

  def success?
    status == :success
  end

  def failed?
    status == :failed
  end

  def canceled?
    status == :canceled
  end

  def started?
    !pending? && started_at
  end

  def active?
    running? || pending?
  end

  def complete?
    success? || failed?
  end

  def compare?
    gitlab? && before_sha
  end

  def gitlab?
    project.gitlab?
  end

  def ci_skip?
    !!(git_commit_message =~ /(\[ci skip\])/)
  end

  def head?
    ref_type == 'heads'
  end

  def tag?
    ref_type == 'tags'
  end

  def git_author_name
    commit_data[:author][:name] if commit_data && commit_data[:author]
    commit_data[:author_name] if commit_data
  end

  def git_author_email
    commit_data[:author][:email] if commit_data && commit_data[:author]
    commit_data[:author_email] if commit_data
  end

  def git_commit_message
    commit_data[:message] if commit_data
  end

  def short_before_sha
    before_sha[0..8]
  end

  def short_sha
    sha[0..8]
  end

  def build_id
    project.builds.where("id <= ?", id).count
  end

  def build_concurrent_id
    project.builds.where(sha: sha).where("id <= ?", id).count
  end

  def commit_data
    push_data[:commits].each do |commit|
      return commit if commit[:id] == sha
    end
  rescue
    nil
  end

  def timeout
    project.timeout
  end

  def allow_git_fetch
    project.allow_git_fetch
  end

  def project_name
    project.name
  end

  def project_recipients
    recipients = project.email_recipients.split(' ')
    recipients << git_author_email if project.email_add_committer?
    recipients.uniq
  end

  def duration
    if started_at && finished_at
      finished_at - started_at
    elsif started_at
      Time.now - started_at
    end
  end

  def started_at
    builds.where.not(started_at: nil).minimum(:started_at)
  end

  def finished_at
    builds.where.not(finished_at: nil).minimum(:finished_at)
  end

  def wait
    if started_at
      started_at - created_at
    else
      Time.now - created_at
    end
  end

  def cancel
    builds.each do |other_build|
      other_build.cancel
    end
  end
end