class Project < ActiveRecord::Base
  attr_accessible :name, :path, :scripts, :timeout, :token,
    :default_ref, :gitlab_url, :always_build, :polling_interval, :public

  has_many :builds, dependent: :destroy


  #
  # Validations
  #
  validates_presence_of :name, :scripts, :timeout, :token, :default_ref, :gitlab_url
  validates_uniqueness_of :name

  validates :polling_interval,
    presence: true,
    if: ->(project) { project.always_build.present? }


  scope :public, where(public: true)

  before_validation :set_default_values

  def set_default_values
    self.token = SecureRandom.hex(15) if self.token.blank?
  end

  def register_build(opts={})
    ref = opts[:ref]

    raise 'ref is not defined' unless ref

    if ref.include? 'heads'
      ref = ref.scan(/heads\/(.*)$/).flatten[0]
    end

    before_sha = opts[:before]
    sha = opts[:after]

    data = {
      project_id: self.id,
      ref: ref,
      sha: sha,
      before_sha: before_sha,
      push_data: opts
    }

    @build = Build.create(data)
  end

  def gitlab?
    gitlab_url.present?
  end

  def status
    last_build.status if last_build
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

  def status_image ref = 'master'
    build = self.builds.where(ref: ref).last
    image_for_build build
  end

  def last_build_for_sha sha
    builds.where(sha: sha).order('id DESC').limit(1).first
  end

  def sha_status_image sha
    build = last_build_for_sha(sha)
    image_for_build build
  end

  def image_for_build build
    return 'unknown.png' unless build

    if build.success?
      'success.png'
    elsif build.failed?
      'failed.png'
    elsif build.active?
      'running.png'
    else
      'unknown.png'
    end
  end

  def tracked_refs
    @tracked_refs ||= default_ref.split(",").map{|ref| ref.strip}
  end

  def valid_token? token
    self.token && self.token == token
  end

  def no_running_builds?
    # Get running builds not later than 3 days ago to ignore hungs
    builds.running.where("updated_at > ?", 3.days.ago).empty?
  end
end


# == Schema Information
#
# Table name: projects
#
#  id          :integer(4)      not null, primary key
#  name        :string(255)     not null
#  path        :string(255)     not null
#  timeout     :integer(4)      default(1800), not null
#  scripts     :text            default(""), not null
#  created_at  :datetime        not null
#  updated_at  :datetime        not null
#  token       :string(255)
#  default_ref :string(255)
#
