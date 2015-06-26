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
    !new_branch?
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
    return if skip_ci?

    begin
      builds_for_ref = config_processor.builds_for_ref(ref, tag)
    rescue GitlabCiYamlProcessor::ValidationError => e
      save_yaml_error(e.message) and return
    rescue Exception => e
      logger.error e.message + "\n" + e.backtrace.join("\n")
      save_yaml_error("Undefined yaml error") and return
    end

    builds_for_ref.each do |build_attrs|
      builds.create!({
        project: project,
        name: build_attrs[:name],
        commands: build_attrs[:script],
        tag_list: build_attrs[:tags]
      })
    end
  end

  def builds_without_retry
    @builds_without_retry ||=
      begin
        grouped_builds = builds.group_by(&:name)
        grouped_builds.map do |name, builds|
          builds.sort_by(&:id).last
        end
      end
  end

  def retried_builds
    @retried_builds ||= (builds - builds_without_retry)
  end

  def create_deploy_builds
    return if skip_ci?

    begin
      deploy_builds_for_ref = config_processor.deploy_builds_for_ref(ref, tag)
    rescue GitlabCiYamlProcessor::ValidationError => e
      save_yaml_error(e.message) and return
    rescue Exception => e
      logger.error e.message + "\n" + e.backtrace.join("\n")
      save_yaml_error("Undefined yaml error") and return
    end

    deploy_builds_for_ref.each do |build_attrs|
      builds.create!({
        project: project,
        name: build_attrs[:name],
        commands: build_attrs[:script],
        tag_list: build_attrs[:tags],
        deploy: true
      })
    end
  end

  def status
    if yaml_errors.present?
      return 'failed'
    end

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
    @finished_at ||= builds.order('finished_at DESC').first.try(:finished_at)
  end

  def coverage
    if project.coverage_enabled? && builds.count(:all) > 0
      coverage_array = builds.map(&:coverage).compact
      if coverage_array.size >= 1
        coverage_array.reduce(:+) / coverage_array.size
      end
    end
  end

  def matrix?
    builds_without_retry.size > 1
  end

  def config_processor
    @config_processor ||= GitlabCiYamlProcessor.new(push_data[:ci_yaml_file] || project.generated_yaml_config)
  end

  def skip_ci?
    commits = push_data[:commits]
    commits.present? && commits.last[:message] =~ /(\[ci skip\])/
  end

  private

  def save_yaml_error(error)
    self.yaml_errors = error
    save
  end
end
