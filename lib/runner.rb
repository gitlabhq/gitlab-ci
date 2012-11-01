require 'open3'
require 'timeout'

class Runner
  TIMEOUT = 1800
  attr_accessor :project, :build, :output

  @queue = :runner

  def self.perform(build_id)
    new(Build.find(build_id)).run
  end

  def initialize(build)
    @logger = Logger.new(STDOUT)
    @logger.level = Logger::INFO

    @build = build
    @project = build.project
    @output = ''
  end

  def run
    path = project.path
    commands = project.scripts



    Dir.chdir(path) do
      commands.each_line do |line|
        status = command(line, path)
        build.write_trace(@output)

        unless status
          build.fail!
          return
        end
      end
    end

    build.success!
  rescue Errno::ENOENT
    @output << "INVALID PROJECT PATH"
    build.fail!
  rescue Timeout::Error
    @output << "TIMEOUT"
    build.fail!
  ensure
    build.write_trace(@output)
  end

  def command(cmd, path)
    cmd = cmd.strip
    status = 0

    @output ||= ""
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

    Timeout.timeout(project.timeout) do
      Open3.popen3(vars, cmd, options) do |stdin, stdout, stderr, wait_thr|
        status = wait_thr.value.exitstatus
        @pid = wait_thr.pid
        @output << stdout.read
        @output << stderr.read
      end
    end

    status == 0
  end
end
