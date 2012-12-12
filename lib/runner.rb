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
    commands = commands.lines.to_a
    commands.unshift(prepare_project_cmd(path, build.sha))

    build.run!

    Dir.chdir(path) do
      commands.each do |line|
        status = command(line, path)
        build.write_trace(@output)

        return if build.canceled?

        unless status
          build.drop!
          return
        end
      end
    end

    build.success!
  rescue Errno::ENOENT => ex

    @output << "INVALID PROJECT PATH"
    build.drop!
  rescue Timeout::Error
    @output << "TIMEOUT"
    build.drop!
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

    # ENV
    @process.environment['BUNDLE_GEMFILE'] = File.join(path, 'Gemfile')
    @process.environment['BUNDLE_BIN_PATH'] = ''
    @process.environment['RUBYOPT'] = ''

    @process.start

    build.set_file @tmp_file.path

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

  def prepare_project_cmd(path, ref)
    cmd = []
    cmd << "cd #{path}"
    cmd << "git fetch"
    cmd << "git reset --hard"
    cmd << "git checkout #{ref}"
    cmd.join(" && ")
  end
end
