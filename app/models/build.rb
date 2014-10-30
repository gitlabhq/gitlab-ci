# == Schema Information
#
# Table name: builds
#
#  id          :integer          not null, primary key
#  project_id  :integer
#  ref         :string(255)
#  ref_type    :string(255)
#  status      :string(255)
#  finished_at :datetime
#  trace       :text
#  created_at  :datetime
#  updated_at  :datetime
#  sha         :string(255)
#  started_at  :datetime
#  tmp_file    :string(255)
#  before_sha  :string(255)
#  push_data   :text
#  runner_id   :integer
#

require 'travis/build'
require 'shellwords'

class Build < ActiveRecord::Base
  belongs_to :project
  belongs_to :runner
  belongs_to :build_group

  serialize :push_data
  serialize :build_attributes
  serialize :matrix_attributes

  attr_accessible :project_id, :ref, :ref_type, :sha, :before_sha,
    :status, :finished_at, :trace, :started_at, :push_data, :runner_id, :project_name, :coverage

  attr_accessible :build_method, :build_attributes, :matrix_attributes, :labels

  attr_accessible :build_group_id

  validates :before_sha, presence: true
  validates :sha, presence: true
  validates :ref, presence: true
  validates :ref_type, presence: true
  validates :status, presence: true
  validate :valid_commit_sha
  validates :coverage, numericality: true, allow_blank: true
  validates :build_method, presence: true

  scope :running, ->() { where(status: "running") }
  scope :pending, ->() { where(status: "pending") }
  scope :success, ->() { where(status: "success") }
  scope :failed, ->() { where(status: "failed")  }
  scope :finished, ->() { where(status: [:success, :failed]) }
  scope :canceled, ->() { where(status: "canceled")  }
  scope :uniq_sha, ->() { select('DISTINCT(sha)') }

  scope :heads, ->() { where(ref_type: "heads") }
  scope :tags, ->() { where(ref_type: "tags") }

  def self.last_month
    where('created_at > ?', Date.today - 1.month)
  end

  def self.first_pending
    pending.where(runner_id: nil).order('created_at ASC').first
  end

  def self.create_from(build)
    new_build = CreateBuildService.new.execute(project, build)
    new_build.save
  end

  state_machine :status, initial: :pending do
    event :run do
      transition pending: :running
    end

    event :drop do
      transition [:pending, :running] => :failed
    end

    event :success do
      transition running: :success
    end

    event :cancel do
      transition [:pending, :running] => :canceled
    end

    after_transition :pending => :running do |build, transition|
      project = build.project

      if project.slack_notification?
        SlackNotificationService.new.build_started(build)
      end

      build.update_attributes started_at: Time.now
    end

    after_transition any => [:success, :failed, :canceled] do |build, transition|
      build.update_attributes finished_at: Time.now
      project = build.project

      if project.web_hooks?
        WebHookService.new.build_end(build)
      end

      CreateBuildService.new.build_end(build)

      if project.email_notification?
        if build.status.to_sym == :failed || !project.email_only_broken_builds
          NotificationService.new.build_ended(build)
        end
      end

      if project.coverage_enabled?
        build.update_coverage
      end

      if project.slack_notification?
        if build.status.to_sym == :failed || !project.slack_only_broken_builds
          SlackNotificationService.new.build_ended(build)
        end
      end
    end

    state :pending, value: 'pending'
    state :running, value: 'running'
    state :failed, value: 'failed'
    state :success, value: 'success'
    state :canceled, value: 'canceled'
  end

  def valid_commit_sha
    if self.sha =~ /\A00000000/
      self.errors.add(:sha, " cant be 00000000 (branch removal)")
    end
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

  def one?
    build_group.nil? or build_group.one?
  end

  def build_service
    CreateBuildService.new.build_service(build_method || project.build_method)
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
    build_group.builds.where("id <= ?", id).count
  end

  def trace_html
    html = Ansi2html::convert(trace) if trace.present?
    html ||= ''
  end

  def started?
    !pending? && !canceled? && started_at
  end

  def active?
    running? || pending?
  end

  def complete?
    canceled? || success? || failed?
  end

  def build_attributes_formatted
    build_service.format_build_attributes(self)
  end

  def matrix_attributes_formatted
    build_service.format_matrix_attributes(self)
  end

  def commands
    build_service.build_commands(self)
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

  def repo_slug
    repo_url.split('/').last(2).join('/').gsub(/\.git$/, '')
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

  def wait
    if started_at
      started_at - created_at
    else
      Time.now - created_at
    end
  end

  def update_coverage
    coverage = extract_coverage(trace, project.coverage_regex)

    if coverage.is_a? Numeric
      update_attributes(coverage: coverage)
    end
  end

  def extract_coverage(text, regex)
    begin
      matches = text.gsub(Regexp.new(regex)).to_a.last
      coverage = matches.gsub(/\d+(\.\d+)?/).first

      if coverage.present?
        coverage.to_f
      end
    rescue => ex
      # if bad regex or something goes wrong we dont want to interrupt transition
      # so we just silentrly ignore error for now
    end
  end
end
