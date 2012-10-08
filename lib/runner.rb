require 'open3'
class Runner
  attr_accessor :project, :build, :output

  @queue = :runner

  def self.perform(build_id)
    new(Build.find(build_id)).run
  end

  def initialize(build)
    @build = build
    @project = build.project
    @output = ''
  end

  def run
    path = project.path
    commands = project.scripts

    Dir.chdir(path) do
      commands.each_line do |line|
        unless command(line, path)
          build.fail!
        end
      end
    end

    build.success!
  end

  def command(cmd, path)
    cmd = cmd.strip

    @output << "\n"
    @output << cmd
    @output << "\n"

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

    Open3.popen3(vars, cmd, options) do |stdin, stdout, stderr|
      @output << stdout.read

      build.update_attributes(trace: @output)
    end

    $?.exitstatus == 0
  end
end
