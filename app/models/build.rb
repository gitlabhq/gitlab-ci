# == Schema Information
#
# Table name: builds
#
#  id          :integer          not null, primary key
#  project_id  :integer
#  ref         :string(255)
#  status      :string(255)
#  finished_at :datetime
#  trace       :text(2147483647)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  sha         :string(255)
#  started_at  :datetime
#  tmp_file    :string(255)
#  before_sha  :string(255)
#  push_data   :text
#  runner_id   :integer
#

class Build < ActiveRecord::Base
  belongs_to :project
  belongs_to :runner

  serialize :push_data

  attr_accessible :project_id, :ref, :sha, :before_sha,
    :status, :finished_at, :trace, :started_at, :push_data, :runner_id, :project_name

  validates :sha, presence: true
  validates :ref, presence: true
  validates :status, presence: true

  scope :running, ->() { where(status: "running") }
  scope :pending, ->() { where(status: "pending") }
  scope :success, ->() { where(status: "success") }
  scope :failed, ->() { where(status: "failed")  }
  scope :uniq_sha, ->() { select('DISTINCT(sha)') }

  def self.last_month
    where('created_at > ?', Date.today - 1.month)
  end

  def self.first_pending
    pending.where(runner_id: nil).order('created_at ASC').first
  end

  def self.create_from(build)
    new_build = build.dup
    new_build.status = :pending
    new_build.runner_id = nil
    new_build.save
  end

  state_machine :status, initial: :pending do
    event :run do
      transition pending: :running
    end

    event :drop do
      transition running: :failed
    end

    event :success do
      transition running: :success
    end

    event :cancel do
      transition [:pending, :running] => :canceled
    end

    after_transition :pending => :running do |build, transition|
      build.update_attributes started_at: Time.now
    end

    after_transition any => [:success, :failed, :canceled] do |build, transition|
      build.update_attributes finished_at: Time.now
      project = build.project

      if project.email_notification?
        if build.status.to_sym == :failed || !project.email_all_broken_builds
          NotificationService.new.build_ended(build)
        end
      end
    end

    state :pending, value: 'pending'
    state :running, value: 'running'
    state :failed, value: 'failed'
    state :success, value: 'success'
    state :canceled, value: 'canceled'
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

  def git_author_name
    commit_data[:author][:name] if commit_data && commit_data[:author]
  end

  def git_author_email
    commit_data[:author][:email] if commit_data && commit_data[:author]
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

  def trace_html
    html = Ansi2html::convert(trace) if trace.present?
    html ||= ''
  end

  def to_param
    sha
  end

  def started?
    !pending? && !canceled? && started_at
  end

  def active?
    running? || pending?
  end

  def commands
    project.scripts
  end

  def commit_data
    push_data[:commits].each do |commit|
      return commit if commit[:id] == sha
    end
  rescue
    nil
  end

  # Build a clone-able repo url
  # using http and basic auth
  def repo_url
    auth = "gitlab-ci-token:#{project.token}@"
    url = project.gitlab_url + ".git"
    url.sub(/^https?:\/\//) do |prefix|
      prefix + auth
    end
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
end
