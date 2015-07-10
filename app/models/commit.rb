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
#  tag         :boolean          default(FALSE)
#  yaml_errors :text
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

  def job_type
    return unless config_processor
    job_types = builds_without_retry.select(&:active?).map(&:job_type)
    config_processor.types.find { |job_type| job_types.include? job_type }
  end

  def create_builds_for_type(job_type)
    return if skip_ci?
    return unless config_processor

    builds_attrs = config_processor.builds_for_type_and_ref(job_type, ref, tag)
    builds_attrs.map do |build_attrs|
      builds.create!({
        project: project,
        name: build_attrs[:name],
        commands: build_attrs[:script],
        tag_list: build_attrs[:tags],
        options: build_attrs[:options],
        allow_failure: build_attrs[:allow_failure],
        job_type: build_attrs[:type]
      })
    end
  end

  def create_next_builds
    return if skip_ci?
    return unless config_processor

    build_types = builds.group_by(&:job_type)

    config_processor.types.any? do |job_type|
      !build_types.include?(job_type) && create_builds_for_type(job_type).present?
    end
  end

  def create_builds
    return if skip_ci?
    return unless config_processor

    config_processor.types.any? do |job_type|
      create_builds_for_type(job_type).present?
    end
  end

  def builds_without_retry
    return unless config_processor
    @builds_without_retry ||=
      begin
        job_types = config_processor.types
        grouped_builds = builds.group_by(&:name)
        grouped_builds = grouped_builds.map do |name, builds|
          builds.sort_by(&:id).last
        end
        grouped_builds.sort_by do |build|
          [job_types.index(build.job_type), build.name]
        end
      end
  end

  def retried_builds
    @retried_builds ||= (builds.order(id: :desc) - builds_without_retry)
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
      build.success? || build.ignored?
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
    if project.coverage_enabled?
      coverage_array = builds_without_retry.map(&:coverage).compact
      if coverage_array.size >= 1
        '%.2f' % (coverage_array.reduce(:+) / coverage_array.size)
      end
    end
  end

  def matrix?
    builds_without_retry.size > 1
  end

  def config_processor
    @config_processor ||= GitlabCiYamlProcessor.new(push_data[:ci_yaml_file] || project.generated_yaml_config)
  rescue GitlabCiYamlProcessor::ValidationError => e
    save_yaml_error(e.message)
    nil
  rescue Exception => e
    logger.error e.message + "\n" + e.backtrace.join("\n")
    save_yaml_error("Undefined yaml error")
    nil
  end

  def skip_ci?
    commits = push_data[:commits]
    commits.present? && commits.last[:message] =~ /(\[ci skip\])/
  end

  private

  def save_yaml_error(error)
    return unless self.yaml_errors?
    self.yaml_errors = error
    save
  end
end
