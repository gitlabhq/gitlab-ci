class Project < ActiveRecord::Base
  attr_accessible :name, :path, :scripts, :timeout, :token, :default_ref

  validates_presence_of :name, :path, :scripts, :timeout, :token, :default_ref

  has_many :builds, dependent: :destroy

  validate :repo_present?

  def repo_present?
    repo
  rescue Grit::NoSuchPathError, Grit::InvalidGitRepositoryError
    errors.add(:path, 'Project path is not a git repository')
    false
  end

  def register_build opts={}
    ref = opts[:ref] || default_ref || 'master'

    data = {
      project_id: self.id,
      status: 'running',
      ref: ref,
      sha: last_commit(ref)
    }

    @build = Build.create(data)
  end

  def status
    if last_build
      last_build.status
    end
  end

  def last_build
    builds.last
  end

  def last_build_date
    last_build.try(:updated_at)
  end

  def human_status
    status
  end

  def status_image
    if status == 'success'
      'success.png'
    elsif status == 'fail'
      'failed.png'
    else
      'unknown.png'
    end
  end

  def repo
    @repo ||= Grit::Repo.new(path)
  end

  def last_commit(ref)
    repo.commits(ref, 1).first.sha
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

