require 'open3'
require 'timeout'

class Runner
  include Sidekiq::Worker

  attr_accessor :project, :build, :output

  sidekiq_options queue: :runner

  def perform(build_id)
    @build = Build.find(build_id)
    @project = @build.project
    @output = ''

    return true if @build.canceled?

    run_in_transaction ? run : run_later
  end

  def run_in_transaction
    ActiveRecord::Base.transaction do
      build.run! if project.no_running_builds?
    end
  end

  def run_later
    Runner.perform_in(2.minutes, @build.id)
  end

  def initialize
    @logger = Logger.new(STDOUT)
    @logger.level = Logger::INFO
  end

  def run
    path = project.path
    commands = project.scripts
    commands = commands.lines.to_a
    commands.unshift(prepare_project_cmd(path, build.sha))

    commands.each do |line|
      status = command(line, path)
      build.write_trace(@output)

      return if build.canceled?

      unless status
        build.drop!
        return
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
    @tmp_file = Tempfile.new("child-output", binmode: true)
    @process.io.stdout = @tmp_file
    @process.io.stderr = @tmp_file
    @process.cwd = path

    # ENV
    @process.environment['BUNDLE_GEMFILE'] = File.join(path, 'Gemfile')
    @process.environment['BUNDLE_BIN_PATH'] = ''
    @process.environment['RUBYOPT'] = ''

    @process.environment['CI_SERVER'] = 'yes'
    @process.environment['CI_SERVER_NAME'] = 'GitLab CI'
    @process.environment['CI_SERVER_VERSION'] = GitlabCi::Version
    @process.environment['CI_SERVER_REVISION'] = GitlabCi::Revision

    @process.environment['CI_BUILD_REF'] = build.ref

    @process.start

    build.set_file @tmp_file.path

    begin
      @process.poll_for_exit(project.timeout)
    rescue ChildProcess::TimeoutError
      @process.stop # tries increasingly harsher methods to kill the process.
    end

    @process.exit_code == 0

  rescue => e
    # return false if any exception occurs
    @output << e.message
    false

  ensure
    @tmp_file.rewind
    @output << GitlabCi::Encode.encode!(@tmp_file.read)
    @tmp_file.close
    @tmp_file.unlink
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
