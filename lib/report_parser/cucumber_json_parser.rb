require 'json'

module ReportParser
  class CucumberJson
    def self.parse(content, build)
      cucumber = JSON.parse(content)
      ret = { status: 'empty', duration: 0.0 }
      report = TestReport.new do |r|
        r.title= 'Cucumber Reports'
        r.build= build
      end
      report.save
      cucumber.map do |feature|
        feat = add_feature(feature, build)
        ret[:status] = feat[:status] unless ret[:status]=='failed'
      end
      report.duration = ret[:duration]
      report.status = ret[:status]
      report.save
      return 'success' if ret[:status] == 'success'
      'failed'
    end

    def self.add_feature(feature,report)
      report = TestReport.new do |r|
        r.title= feature["keyword"] + " " + feature["name"]
        r.description= feature["description"]
        r.location= "#{feature["uri"]}:#{feature["line"]}"
        r.parent= report
      end
      ret = { status: 'empty', duration: 0.0 }
      feature["elements"].each do |elem|
        elem = add_element(elem, report)
        ret[:status] = elem[:status] unless ret[:status]=='failed'
        ret[:duration] += elem[:duration]
      end if feature["elements"]
      report.duration = ret[:duration]
      report.status = ret[:status]
      report.save
      ret
    end

    def self.add_element(elem, report)
      element = TestReport.new do |r|
        r.title= elem["keyword"] + " " + elem["name"]
        r.description= elem["description"]
        r.location= "#{elem["uri"]}:#{elem["line"]}"
        r.parent= report
      end
      ret = { status: 'empty', duration: 0.0 }
      elem["steps"].each do |step|
        step = add_step(step, element)
        ret[:status] = step[:status] unless ret[:status]=='failed'
        ret[:duration] += step[:duration]
      end if elem["steps"]
      element.duration = ret[:duration]
      element.status = ret[:status]
      element.save
      ret
    end
    def self.add_step(step, element)
      st = TestReport.new do |r|
        r.title= step["keyword"] + " " + step["name"]
        r.description= step["description"]
        r.location= "#{step["match"]["location"] if step["match"]}:#{step["line"]}"
        r.parent= element
        r.error_message= step["result"]["error_message"] if step["result"]
        r.status= status(step)
        r.duration= duration(step)
      end
      st.save

      { status: status(step), duration: duration(step) }
    end

    def self.duration(step)
      if step["result"].nil? or step["result"]["duration"].nil?
        return 0.0
      end
      step["result"]["duration"].to_f / 1e9
    end

    def self.status(step)
      status = (step["result"])? step["result"]["status"] : 'failed'
      status.gsub /passed/, 'success'
    end
  end
end