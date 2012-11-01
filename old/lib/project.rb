require_relative 'build'

class Project < ActiveRecord::Base
  attr_accessible :name, :path, :scripts

  validates_presence_of :name, :path, :scripts

  has_many :builds

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

  def human_status
    status
  end
end
