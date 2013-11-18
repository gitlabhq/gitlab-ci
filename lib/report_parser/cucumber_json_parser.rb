require 'json'

module ReportParser
  class CucumberJson
    def self.parse(content, build)
      cucumber = JSON.parse(content)
      ret = { status: 'empty', duration: 0.0 }
      ActiveRecord::Base.transaction do
        report = TestReport.new do |r|
          r.title= 'Cucumber Reports'
          r.build= build
        end
        cucumber.map do |feature|
          feat = add_feature(feature, report)
          ret[:status] = feat[:status] unless ret[:status]=='failed'
          ret[:duration] += feat[:duration]
        end
        report.duration = ret[:duration]
        report.status = ret[:status]
        report.save
      end
      return 'failed' if ret[:status] == 'failed'
      'success'
    end

    def self.add_feature(feature,report)
      report = TestReport.new do |r|
        r.title= feature["keyword"] + " " + feature["name"]
        r.description= feature["description"]
        r.location= "#{feature["uri"]}:#{feature["line"]}"
        r.error_message = examples(feature['examples']) unless feature['examples'].nil?
        r.parent= report
      end
      ret = { status: 'empty', duration: 0.0 }
      feature["elements"].each do |elem|
        elem = add_element(elem, report)
        ret[:status] = elem[:status] if ret[:status]=='success' or ret[:status]=='empty'
        ret[:duration] += elem[:duration]
      end if feature["elements"]
      report.duration = ret[:duration]
      report.status = ret[:status]
      report.save
      ret
    end

    def self.add_element(json, report)
      ret = { status: 'empty', duration: 0.0 }
      element = create_element(json, report)
      if json['keyword'] == 'Scenario Outline'
        ret[:status] = 'pending'
        element.status = 'pending'
        element.error_message = "#{element.error_message} <br />
<p class='alert alert-error'>This step is marked as pending as it's impossible currently to determin the currect state due to an bug in Gherkin
<br />See the <a href='https://github.com/cucumber/gherkin/issues/165'>bugreport</a> for more information
<p>".html_safe
      end
      json['steps'].each do |step|
        step = add_step(step, element)
        ret[:status] = step[:status] if ret[:status]=='success' or ret[:status]=='empty'
        ret[:duration] += step[:duration]
      end if json['steps']
      element.duration = ret[:duration]
      element.status = ret[:status]
      element.save
      ret
    end

    def self.create_element(json, report)
      TestReport.new do |r|
        r.title= json["keyword"] + " " + json["name"]
        r.description= json["description"]
        r.location= "#{json["uri"]}:#{elem["line"]}" unless json["uri"].blank?
        r.error_message = examples(json['examples']) unless json['examples'].blank?
        r.parent= report
      end
    end

    def self.add_step(json, element)
      st = TestReport.new do |r|
        r.title= json["keyword"] + " " + json["name"]
        r.description= json["description"]
        r.location= location(json["match"])
        r.parent= element
        r.error_message= json["result"]["error_message"] if json["result"]
        r.status= status(json)
        r.duration= duration(json)
      end
      st.save

      { status: status(json), duration: duration(json) }
    end

    def self.location(step)
      return '' if step.nil?
      "#{step["location"]}:#{step["line"]}"
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

    def self.examples(example)
      rows = example.first["rows"]
      rows.shift
      (rows.map { |row| row['cells'].join ',' }.join '<br />').html_safe
    end
  end
end