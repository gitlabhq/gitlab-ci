
module ReportParser
  class RSpecJson
    def self.parse(content, build)
      test = TestReport.new do |r|
        r.title = 'Implementation missing'
        r.error_message = 'The implementation of the RSpec Report Parser is missing!'
        r.status = 'failed'
        r.build = build
      end
      test.save
    end
  end
end