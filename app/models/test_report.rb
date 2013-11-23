class TestReport < ActiveRecord::Base
  acts_as_nested_set
  attr_accessible :title, :error_message, :status, :build, :location, :duration, :description, :parent_id
  belongs_to :build
end
