# == Schema Information
#
# Table name: projects
#
#  id                       :integer          not null, primary key
#  name                     :string(255)      not null
#  timeout                  :integer          default(1800), not null
#  scripts                  :text             not null
#  created_at               :datetime
#  updated_at               :datetime
#  token                    :string(255)
#  default_ref              :string(255)
#  gitlab_url               :string(255)
#  always_build             :boolean          default(FALSE), not null
#  polling_interval         :integer
#  public                   :boolean          default(FALSE), not null
#  ssh_url_to_repo          :string(255)
#  gitlab_id                :integer
#  allow_git_fetch          :boolean          default(TRUE), not null
#  email_recipients         :string(255)      default(""), not null
#  email_add_committer      :boolean          default(TRUE), not null
#  email_only_broken_builds :boolean          default(TRUE), not null
#

class Project < ActiveRecord::Base
  attr_accessible :name, :path, :scripts, :timeout, :token, :timeout_in_minutes,
    :default_ref, :gitlab_url, :always_build, :polling_interval,
    :public, :ssh_url_to_repo, :gitlab_id, :allow_git_fetch, :skip_refs,
    :email_recipients, :email_add_committer, :email_only_broken_builds, :coverage_regex

  has_many :builds, dependent: :destroy
  has_many :runner_projects, dependent: :destroy
  has_many :runners, through: :runner_projects
  has_many :web_hooks, dependent: :destroy

  #
  # Validations
  #
  validates_presence_of :name, :scripts, :timeout, :token, :default_ref, :gitlab_url, :ssh_url_to_repo, :gitlab_id

  validates_uniqueness_of :name

  validates :polling_interval,
    presence: true,
    if: ->(project) { project.always_build.present? }


  scope :public_only, ->() { where(public: true) }

  before_validation :set_default_values

  class << self
    def base_build_script
      <<-eos
git submodule update --init
ls -la
      eos
    end

    def parse(project_yaml)
      project = YAML.load(project_yaml)

      params = {
        name:                    project.name_with_namespace,
        gitlab_id:               project.id,
        gitlab_url:              project.web_url,
        scripts:                 Project.base_build_script,
        default_ref:             project.default_branch || 'master',
        ssh_url_to_repo:         project.ssh_url_to_repo,
        email_add_committer:     GitlabCi.config.gitlab_ci.add_committer,
        email_only_broken_builds: GitlabCi.config.gitlab_ci.all_broken_builds,
      }

      Project.new(params)
    end

    def from_gitlab(user, page, per_page, scope = :owned)
      opts = { private_token: user.private_token }
      opts[:per_page] = per_page if per_page.present?
      opts[:page]     = page     if page.present?

      projects = Network.new.projects(user.url, opts, scope)

      if projects
        projects.map { |pr| OpenStruct.new(pr) }
      else
        []
      end
    end

    def already_added?(project)
      where(gitlab_url: project.web_url).any?
    end

    def unassigned(runner)
      joins('LEFT JOIN runner_projects ON runner_projects.project_id = projects.id ' \
        "AND runner_projects.runner_id = #{runner.id}").
      where('runner_projects.project_id' => nil)
    end
  end

  def set_default_values
    self.token = SecureRandom.hex(15) if self.token.blank?
  end

  def gitlab?
    gitlab_url.present?
  end

  def status
    last_build.status if last_build
  end

  def broken?
    last_build.failed? || last_build.canceled? if last_build
  end

  def success?
    last_build.success? if last_build
  end

  def broken_or_success?
    broken? || success?
  end

  def last_build
    builds.last
  end

  def last_build_date
    last_build.try(:created_at)
  end

  def human_status
    status
  end

  def last_build_for_sha(sha)
    builds.where(sha: sha).order('id DESC').limit(1).first
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
    email_add_committer || email_recipients.present?
  end

  def web_hooks?
    web_hooks.any?
  end

  # onlu check for toggling build status within same ref.
  def last_build_changed_status?
    ref = last_build.ref
    last_builds = builds.where(ref: ref).order('id DESC').limit(2)
    return false if last_builds.size < 2
    return last_builds[0].status != last_builds[1].status
  end

  def timeout_in_minutes
    timeout / 60
  end

  def timeout_in_minutes=(value)
    self.timeout = value.to_i * 60
  end

  def skip_ref?(ref_name)
    if skip_refs.present?
      skip_refs.delete(" ").split(",").include?(ref_name)
    else
      false
    end
  end

  def coverage_enabled?
    coverage_regex.present?
  end
end
