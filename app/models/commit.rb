# == Schema Information
#
# Table name: commits
#
#  id         :integer          not null, primary key
#  project_id :integer
#  ref        :string(255)
#  sha        :string(255)
#  before_sha :string(255)
#  push_data  :text
#  created_at :datetime
#  updated_at :datetime
#

class Commit < ActiveRecord::Base
  belongs_to :project
  has_many :builds, dependent: :destroy
  has_many :jobs, through: :builds

  serialize :push_data

  validates_presence_of :ref, :sha, :before_sha, :push_data
  validate :valid_commit_sha

  def self.truncate_sha(sha)
    sha[0...8]
  end

  def to_param
    sha
  end

  def last_build
    builds.order(:id).last
  end

  def retry
    builds_without_retry.each do |build|
      Build.retry(build)
    end
  end

  def valid_commit_sha
    if self.sha == Git::BLANK_SHA
      self.errors.add(:sha, " cant be 00000000 (branch removal)")
    end
  end

  def new_branch?
    before_sha == Git::BLANK_SHA
  end

  def compare?
    gitlab? && !new_branch?
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
    commit_data[:message] if commit_data && commit_data[:message]
  end

  def short_before_sha
    Commit.truncate_sha(before_sha)
  end

  def short_sha
    Commit.truncate_sha(sha)
  end

  def commit_data
    push_data[:commits].find do |commit|
      commit[:id] == sha
    end
  rescue
    nil
  end

  def project_recipients
    recipients = project.email_recipients.split(' ')

    if project.email_add_pusher? && push_data[:user_email].present?
      recipients << push_data[:user_email]
    end

    recipients.uniq
  end

  def create_builds
    project.jobs.where(build_branches: true).active.parallel.map do |job|
      create_build_from_job(job)
    end
  end

  def create_builds_for_tag(ref = '')
    project.jobs.where(build_tags: true).active.parallel.map do |job|
      create_build_from_job(job, ref)
    end
  end

  def create_build_from_job(job, ref = '')
    build = builds.new(commands: job.commands)
    build.tag_list = job.tag_list
    build.project_id = project_id
    build.job = job
    build.save
    build
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

  def retried_builds
    @retried_builds ||= (builds - builds_without_retry)
  end

  def create_deploy_builds(ref)
    project.jobs.deploy.active.each do |job|
      if job.run_for_ref?(ref)
        create_build_from_job(job)
      end
    end
  end

  def status
    if success?
      'success'
    elsif pending?
      'pending'
    elsif running?
      'running'
    elsif canceled?
      'canceled'
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
      build.running? || build.pending?
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
    builds_without_retry.all? do |build|
      build.canceled?
    end
  end

  def duration
    @duration ||= builds_without_retry.select(&:duration).sum(&:duration).to_i
  end

  def finished_at
    @finished_at ||= builds.order('finished_at ASC').first.try(:finished_at)
  end

  def coverage
    if project.coverage_enabled? && builds.size > 0
      builds.last.coverage
    end
  end

  def matrix?
    builds_without_retry.size > 1
  end
end
