
module ReportParser
  class RSpecJson
    def self.parse(content, build)
      content = JSON.parse(content)
      ret_status = 'empty'
      unless content["examples"].empty? and content["summary"].nil?
        test = TestReport.new do |r|
          r.title = 'RSpec tests'
          r.duration = content['summary']['duration']
          r.build= build
        end
        test.save
        content["examples"].each do |example|
          state = add_example(example, test)
          ret_status = state unless ret_status=='failed'
        end
        test.status = ret_status
        test.save
      end
      return 'success' if ret_status == 'success'
      'failed'
    end

    def self.add_example(example, test)
      test = TestReport.new do |r|
        r.title = example["description"]
        r.description = example["full_description"]
        r.status = status(example)
        r.location = location(example)
        r.error_message = exception(example["exception"]) if example["exception"]
        r.parent = test
      end
      test.save
      test.status
    end

    def self.status(example)
      state = example["status"]
      state.gsub! /passed/, 'success'
      state
    end

    def self.location(example)
      "#{example["file_path"]}:#{example["line_number"]}"
    end

    def self.exception(example)
      "#{example["message"]} <hr /> #{example["backtrace"].join '<br />'}".html_safe
    end
  end
end