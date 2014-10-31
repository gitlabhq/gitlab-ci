# == Schema Information
#
# Table name: builds
#
#  id          :integer          not null, primary key
#  status      :string(255)
#  finished_at :datetime
#  trace       :text
#  created_at  :datetime
#  updated_at  :datetime
#  started_at  :datetime
#  tmp_file    :string(255)
#  runner_id   :integer
#  commit_id   :integer
#

class Build < ActiveRecord::Base
  belongs_to :commit
  belongs_to :runner

  attr_accessible :status, :finished_at, :trace, :started_at, :runner_id, :commit_id, :coverage

  validates :commit, presence: true
  validates :status, presence: true
  validates :coverage, numericality: true, allow_blank: true

  scope :running, ->() { where(status: "running") }
  scope :pending, ->() { where(status: "pending") }
  scope :success, ->() { where(status: "success") }
  scope :failed, ->() { where(status: "failed")  }

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

      if project.web_hooks?
        WebHookService.new.build_end(build)
      end

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

  def commands
    project.scripts
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


  # The following methods are provided for Grape::Entity and end up being
  # useful everywhere else to reduce the changes needed for parallel builds.
  def ref
    commit.ref
  end

  def sha
    commit.sha
  end

  def short_sha
    commit.short_sha
  end

  def before_sha
    commit.before_sha end

  def allow_git_fetch
    commit.allow_git_fetch
  end

  def project
    commit.project
  end

  def project_id
    commit.project_id
  end

  def project_name
    commit.project_name
  end

  def repo_url
    commit.repo_url
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
