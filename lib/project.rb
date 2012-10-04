require_relative 'build'

class Project < ActiveRecord::Base
  attr_accessible :name, :path, :scripts

  validates_presence_of :name, :path, :scripts

  has_many :builds

  def status
    if last_build
      last_build.status
    end
  end

  def last_build
    builds.last
  end
end
