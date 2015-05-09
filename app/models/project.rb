# == Schema Information
#
# Table name: projects
#
#  id                       :integer          not null, primary key
#  name                     :string(255)      not null
#  timeout                  :integer          default(1800), not null
#  created_at               :datetime
#  updated_at               :datetime
#  token                    :string(255)
#  default_ref              :string(255)
#  path                     :string(255)
#  always_build             :boolean          default(FALSE), not null
#  polling_interval         :integer
#  public                   :boolean          default(FALSE), not null
#  ssh_url_to_repo          :string(255)
#  gitlab_id                :integer
#  allow_git_fetch          :boolean          default(TRUE), not null
#  email_recipients         :string(255)      default(""), not null
#  email_add_pusher         :boolean          default(TRUE), not null
#  email_only_broken_builds :boolean          default(TRUE), not null
#  skip_refs                :string(255)
#  coverage_regex           :string(255)
#  shared_runners_enabled   :boolean          default(FALSE)
#  cache_pattern            :string(255)      default(""), not null
#

class Project < ActiveRecord::Base
  include ProjectStatus

  has_many :commits, dependent: :destroy
  has_many :builds, through: :commits, dependent: :destroy
  has_many :runner_projects, dependent: :destroy
  has_many :runners, through: :runner_projects
  has_many :web_hooks, dependent: :destroy
  has_many :jobs, dependent: :destroy
  has_many :events, dependent: :destroy

  # Project services
  has_many :services, dependent: :destroy
  has_one :hip_chat_service, dependent: :destroy
  has_one :slack_service, dependent: :destroy
  has_one :mail_service, dependent: :destroy

  accepts_nested_attributes_for :jobs, allow_destroy: true

  #
  # Validations
  #
  validates_presence_of :name, :timeout, :token, :default_ref,
    :path, :ssh_url_to_repo, :gitlab_id

  validates_uniqueness_of :name

  validates :polling_interval,
    presence: true,
    if: ->(project) { project.always_build.present? }

  validate :validate_jobs

  scope :public_only, ->() { where(public: true) }

  before_validation :set_default_values

  class << self
    def base_build_script
      <<-eos
git submodule update --init
ls -la
      eos
    end

    def parse(project_params)
      project = if project_params.is_a?(String)
                  YAML.load(project_params)
                else
                  project_params
                end

      params = {
        name:                    project.name_with_namespace,
        gitlab_id:               project.id,
        path:                    project.path_with_namespace,
        default_ref:             project.default_branch || 'master',
        ssh_url_to_repo:         project.ssh_url_to_repo,
        email_add_pusher:        GitlabCi.config.gitlab_ci.add_pusher,
        email_only_broken_builds: GitlabCi.config.gitlab_ci.all_broken_builds,
      }

      project = Project.new(params)
      project.build_missing_services
      project
    end

    def from_gitlab(user, scope = :owned, options)
      opts = { private_token: user.private_token }
      opts.merge! options

      projects = Network.new.projects(opts.compact, scope)

      if projects
        projects.map { |pr| OpenStruct.new(pr) }
      else
        []
      end
    end

    def already_added?(project)
      where(gitlab_id: project.id).any?
    end

    def unassigned(runner)
      joins('LEFT JOIN runner_projects ON runner_projects.project_id = projects.id ' \
        "AND runner_projects.runner_id = #{runner.id}").
      where('runner_projects.project_id' => nil)
    end

    def ordered_by_last_commit_date
      last_commit_subquery = "(SELECT project_id, MAX(created_at) created_at FROM commits GROUP BY project_id)"
      joins("LEFT JOIN #{last_commit_subquery} AS last_commit ON projects.id = last_commit.project_id").
        order("CASE WHEN last_commit.created_at IS NULL THEN 1 ELSE 0 END, last_commit.created_at DESC")
    end

    def search(query)
      where('LOWER(projects.name) LIKE :query',
            query: "%#{query.try(:downcase)}%")
    end
  end

  def set_default_values
    self.token = SecureRandom.hex(15) if self.token.blank?
  end

  def tracked_refs
    @tracked_refs ||= default_ref.split(",").map{|ref| ref.strip}
  end

  def valid_token? token
    self.token && self.token == token
  end

  def no_running_builds?
    # Get running builds not later than 3 days ago to ignore hangs
    builds.running.where("updated_at > ?", 3.days.ago).empty?
  end

  def email_notification?
    email_add_pusher || email_recipients.present?
  end

  def web_hooks?
    web_hooks.any?
  end

  def services?
    services.any?
  end

  def timeout_in_minutes
    timeout / 60
  end

  def timeout_in_minutes=(value)
    self.timeout = value.to_i * 60
  end

  def cache_pattern_list
    (cache_pattern || '').split(',').map(&:strip)
  end

  def cache_pattern_list=(value)
    self.cache_pattern = value.join(', ')
  end

  def skip_ref?(ref_name)
    if skip_refs.present?
      skip_refs.delete(" ").split(",").each do |ref|
        return true if File.fnmatch(ref, ref_name)
      end

      false
    else
      false
    end
  end

  def create_commit_for_tag?(tag)
    jobs.where(build_tags: true).active.parallel.any? ||
    jobs.active.deploy.any?{ |job| job.run_for_ref?(tag)}
  end

  def coverage_enabled?
    coverage_regex.present?
  end

  def build_default_job
    jobs.build(commands: Project.base_build_script)
  end

  def validate_jobs
    remaining_jobs = jobs.reject(&:marked_for_destruction?)

    if remaining_jobs.empty?
      errors.add(:jobs, "At least one foo")
    end
  end

  # Build a clone-able repo url
  # using http and basic auth
  def repo_url_with_auth
    auth = "gitlab-ci-token:#{token}@"
    url = gitlab_url + ".git"
    url.sub(/^https?:\/\//) do |prefix|
      prefix + auth
    end
  end

  def available_services_names
    %w(slack mail hip_chat)
  end

  def build_missing_services
    available_services_names.each do |service_name|
      service = services.find { |service| service.to_param == service_name }

      # If service is available but missing in db
      # we should create an instance. Ex `create_gitlab_ci_service`
      service = self.send :"create_#{service_name}_service" if service.nil?
    end
  end

  def execute_services(data)
    services.each do |service|

      # Call service hook only if it is active
      begin
        service.execute(data) if service.active
      rescue => e
        logger.error(e)
      end
    end
  end

  def gitlab_url
    File.join(GitlabCi.config.gitlab_server.url, path)
  end

  def setup_finished?
    commits.any?
  end
end
