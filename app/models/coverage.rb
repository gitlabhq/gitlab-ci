class Coverage < ActiveRecord::Base
  attr_accessible :file, :lines, :percentage, :build
  belongs_to :build
end
