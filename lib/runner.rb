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

    @process = ChildProcess.build(cmd)
    @tmp_file = Tempfile.new("child-output")
    @process.io.stdout = @tmp_file
    @process.io.stderr = @tmp_file
    @process.cwd = path
    @process.environment['BUNDLE_GEMFILE'] = ''
    @process.start

    begin
      @process.poll_for_exit(project.timeout)
    rescue ChildProcess::TimeoutError
      @process.stop # tries increasingly harsher methods to kill the process.
    end

    @process.exit_code == 0
  ensure
    @tmp_file.rewind
    @output << @tmp_file.read
  end
end
