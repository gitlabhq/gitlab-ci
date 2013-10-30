class TestReport < ActiveRecord::Base
  attr_accessible :content, :filename
  belongs_to :build
end
