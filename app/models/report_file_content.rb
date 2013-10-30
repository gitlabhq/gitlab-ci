class ReportFileContent < ActiveRecord::Base
  attr_accessible :content, :build_id, :report_file_id
  belongs_to :report_file
  belongs_to :build
end
