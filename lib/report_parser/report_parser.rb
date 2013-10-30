
module ReportParser
  def self.parse(report)
    p report
  end

  autoload :CucumberJson,         'report_parser/cucumber_json_parser'
end