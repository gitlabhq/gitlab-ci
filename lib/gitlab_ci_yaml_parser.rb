# Prototype of parser

class GitlabCiYamlParser
  attr_reader :before_script, :jobs, :on_success

  def initialize(config)
    @before_script = ["pwd"]
    @jobs = [{script: "ruby -v", runner: "", name: "Rspec"}]
    @on_success = [script: "cap deploy production", refs: [], name: "Deploy"]
  end

  def builds
    @jobs.map do |job|
      {
        name: job[:name],
        commands: "#{@before_script.join("\n")}\n#{job[:script]}"
      }
    end
  end

  def deploy_builds
    @on_success.map do |job|
      {
        name: job[:name],
        commands: "#{@before_script.join("\n")}\n#{job[:script]}",
        deploy: true,
        refs: job[:refs]
      }
    end
  end
end