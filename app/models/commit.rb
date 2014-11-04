# == Schema Information
#
# Table name: commits
#
#  id          :integer          not null, primary key
#  project_id  :integer
#  ref         :string(255)
#  sha         :string(255)
#  before_sha  :string(255)
#  push_data   :text
#  created_at  :datetime
#  updated_at  :datetime
#

class Commit < ActiveRecord::Base
  belongs_to :project
  has_many :builds
  has_many :jobs, through: :builds

  serialize :push_data

  validates_presence_of :ref, :sha, :before_sha, :push_data
  validate :valid_commit_sha

  def to_param
    sha
  end

  def last_build
    builds.last
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

  def create_builds
    project.jobs.active.map do |job|
      build = builds.new(commands: job.commands)
      build.job = job
      build.save
      build
    end
  end

  def builds_without_retry
    @builds_without_retry ||=
      begin
        grouped_builds = builds.group_by(&:job)
        grouped_builds.map do |job, builds|
          builds.sort_by(&:id).last
        end
      end
  end

  def status
    if success?
      'success'
    elsif running?
      'running'
    elsif pending?
      'pending'
    else
      'failed'
    end
  end

  def pending?
    builds_without_retry.all? do |build|
      build.pending?
    end
  end

  def running?
    builds_without_retry.any? do |build|
      build.running?
    end
  end

  def success?
    builds_without_retry.all? do |build|
      build.success?
    end
  end

  def failed?
    status == 'failed'
  end

  def canceled?
  end

  def duration
  end

  def finished_at
  end

  def coverage
    if builds.size == 1
      builds.first.coverage
    end
  end
end
