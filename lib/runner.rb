require 'open3'
class Runner
  attr_accessor :project, :build
  @queue = :runner

  def self.perform(build_id)
    new(Build.find(build_id)).run
  end

  def initialize(build)
    @build = build
    @project = build.project
  end

  def run
    trace = ''
    path = project.path
    commands = project.scripts

    Dir.chdir(path) do
      commands.each_line do |line|
        line = line.strip
        trace << "\n"
        cmd = line
        trace << cmd
        trace << "\n"

        vars = {
          "BUNDLE_GEMFILE" => nil,
          "BUNDLE_BIN_PATH" => nil,
          "RUBYOPT" => nil,
          "rvm_" => nil,
          "RACK_ENV" => nil,
          "RAILS_ENV" => nil,
          "PWD" => path
        }
        options = {
          :chdir => path
        }

        stdin, stdout, stderr = Open3.popen3(vars, cmd, options)
        trace << stdout.read

        unless $?.exitstatus == 0
          build.update_attributes(
            trace: trace,
            status: 'fail'
          )

          return false
        end
      end
    end

    build.update_attributes(
      trace: trace,
      status: 'success'
    )
  end
end
