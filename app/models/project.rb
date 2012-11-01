class Project < ActiveRecord::Base
  attr_accessible :name, :path, :scripts, :timeout, :token

  validates_presence_of :name, :path, :scripts, :timeout, :token

  has_many :builds, dependent: :destroy

  def register_build opts={}
    default_opts = {
      project_id: self.id,
      status: 'running'
    }

    allowed_opts = {}
    allowed_opts[:commit_ref] = opts[:after]

    @build = Build.create(default_opts.merge!(allowed_opts))
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
end

# == Schema Information
#
# Table name: projects
#
#  id         :integer(4)      not null, primary key
#  name       :string(255)     not null
#  path       :string(255)     not null
#  timeout    :integer(4)      default(1800), not null
#  scripts    :text            default(""), not null
#  created_at :datetime        not null
#  updated_at :datetime        not null
#  token      :string(255)
#

