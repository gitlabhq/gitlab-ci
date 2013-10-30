class ReportFile < ActiveRecord::Base
  attr_accessible :filename, :filetype, :project_id
  belongs_to :project
  has_many :report_file_contents
end
