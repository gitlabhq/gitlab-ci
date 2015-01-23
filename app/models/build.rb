# == Schema Information
#
# Table name: builds
#
#  id          :integer          not null, primary key
#  project_id  :integer
#  ref         :string(255)
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
#  coverage    :float
#  commit_id   :integer
#  commands    :text
#  job_id      :integer
#

class Build < ActiveRecord::Base
  LAZY_ATTRIBUTES = ['trace']

  belongs_to :commit
  belongs_to :runner
  belongs_to :job

  attr_accessible :status, :finished_at, :trace, :started_at, :runner_id,
    :commit_id, :coverage, :commands, :job_id

  validates :commit, presence: true
  validates :status, presence: true
  validates :coverage, numericality: true, allow_blank: true

  scope :running, ->() { where(status: "running") }
  scope :pending, ->() { where(status: "pending") }
  scope :success, ->() { where(status: "success") }
  scope :failed, ->() { where(status: "failed")  }
  scope :unstarted, ->() { where(runner_id: nil) }

  acts_as_taggable

  # To prevent db load megabytes of data from trace
  default_scope -> { select(Build.columns_without_lazy) }

  class << self
    def columns_without_lazy
      (column_names - LAZY_ATTRIBUTES).map do |column_name|
        "#{table_name}.#{column_name}"
      end
    end

    def last_month
      where('created_at > ?', Date.today - 1.month)
    end

    def first_pending
      pending.unstarted.order('created_at ASC').first
    end

    def create_from(build)
      new_build = build.dup
      new_build.status = :pending
      new_build.runner_id = nil
      new_build.save
    end

    def retry(build)
      new_build = Build.new(status: :pending)

      if build.job
        new_build.commands = build.job.commands
        new_build.tag_list = build.job.tag_list
      else
        new_build.commands = build.commands
      end

      new_build.job_id = build.job_id
      new_build.commit_id = build.commit_id
      new_build.ref = build.ref
      new_build.project_id = build.project_id
      new_build.save
      new_build
    end
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

      if project.web_hooks?
        WebHookService.new.build_end(build)
      end

      project.execute_services(build)

      if project.email_notification?
        if build.status.to_sym == :failed || !project.email_only_broken_builds
          NotificationService.new.build_ended(build)
        end
      end

      if project.coverage_enabled?
        build.update_coverage
      end
    end

    state :pending, value: 'pending'
    state :running, value: 'running'
    state :failed, value: 'failed'
    state :success, value: 'success'
    state :canceled, value: 'canceled'
  end

  delegate :sha, :short_sha, :before_sha,
    to: :commit, prefix: false

  def trace_html
    html = Ansi2html::convert(trace) if trace.present?
    html ||= ''
  end

  def trace
    if project
      read_attribute(:trace).gsub(project.token, 'xxxxxx')
    end
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

  def timeout
    project.timeout
  end

  def duration
    if started_at && finished_at
      finished_at - started_at
    elsif started_at
      Time.now - started_at
    end
  end

  def project
    commit.project
  end

  def project_id
    commit.project_id
  end

  def project_name
    project.name
  end

  def repo_url
    project.repo_url_with_auth
  end

  def allow_git_fetch
    project.allow_git_fetch
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

  def job_name
    if job
      job.name
    end
  end

  def ref
    build_ref = read_attribute(:ref)

    if build_ref.present?
      build_ref
    else
      commit.ref
    end
  end

  def for_tag?
    if job && job.build_tags
      true
    else
      false
    end
  end
end
