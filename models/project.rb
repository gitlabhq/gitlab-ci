class Project < ActiveRecord::Base
  attr_accessible :name, :path, :scripts

  validates_presence_of :name, :path, :scripts
end
