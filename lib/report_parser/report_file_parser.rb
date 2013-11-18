
module ReportParser
  def self.parse(report, build)
    reportFile_id = ReportFile.where(filename: report.file.filename, filetype: report.file.filetype, project_id: build.project.id ).limit(1).pluck(:id).first
    return nil if reportFile_id == nil

    case(report[:file][:filetype].downcase)
      when 'cucumber json format' then CucumberJson.parse(report[:content], build)
      when 'rspec json format' then RSpecJson.parse(report[:content], build)
      else ReportFileContent.new(content: report.content, report_file_id: reportFile_id, build_id: build.id); return 'success'
    end

  rescue JSON::ParserError => ex
    test = TestReport.new do |r|
      r.title = 'Failed JSON report file'
      r.error_message = "<b>#{report.file.filename}</b><br />#{report.content}<hr >/#{ex.inspect}".html_safe
      r.status = 'failed'
      r.build = build
    end
    test.save
    'failed'
  end

  autoload :CucumberJson, 'report_parser/cucumber_json_parser'
  autoload :RSpecJson, 'report_parser/rspec_json'
end