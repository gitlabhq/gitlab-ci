require 'open3'
require 'timeout'
require 'fileutils'

require File.expand_path(File.dirname(__FILE__) + "/travis")

class Runner
  include Sidekiq::Worker

  attr_accessor :project, :build, :output

  sidekiq_options queue: :runner

  def perform(build_id)
    @build = Build.find(build_id)
    @project = @build.project
    @output = ''

    return true if @build.canceled?

    if @project.no_running_builds?
      run
    else
      run_later
    end
  end

  def run_later
    Runner.perform_in(2.minutes, @build.id)
  end

  def initialize
    @logger = Logger.new(STDOUT)
    @logger.level = Logger::INFO
    @default_env = {}
  end

  def run
    path = project.path
    commands = nil

    if project.github?
      commands = github_commands
    else
      commands = project.scripts
      commands = commands.lines.to_a
    end
    commands.unshift(prepare_project_cmd(path, build.sha))

    github_set_env!

    build.run!

    if github_repo_clone?
      commands.unshift github_clone_repo_command
    end

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
  rescue Exception => e
    @output << "ERROR: #{e.message}"
    build.drop!
  ensure
    project.clean_ssh_keys! if project.github?
    build.write_trace(@output)
  end

  def command(cmd, path)
    cmd = cmd.strip
    path = '/tmp' unless File.exists?(path)

    @output ||= ""
    @output << "\n"
    @output << cmd
    @output << "\n"

    @process = ChildProcess.build('sh', '-c', cmd)
    @tmp_file = Tempfile.new("child-output")
    @process.io.stdout = @tmp_file
    @process.io.stderr = @tmp_file
    @process.cwd = path

    # ENV
    gemfile = File.join(path, 'Gemfile')
    @process.environment['BUNDLE_GEMFILE'] = gemfile if File.exists?(gemfile)
    @process.environment['BUNDLE_BIN_PATH'] = ''
    @process.environment['RUBYOPT'] = ''
    @default_env.each_pair do |k,v|
      @process.environment[k] = v
    end

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

  def github_repo_clone?
    project.github? && !project.repo_present?
  end

  def github_clone_repo_command
    "rm -rf '#{project.path}' && git clone #{project.clone_url} '#{project.path}'"
  end

  def github_set_env!
    return unless project.github?
    @default_env = {
      'GIT_SSH' => GithubProject.git_ssh_command,
      'GITLAB_CI_KEY' => project.store_ssh_keys!
    }
  end

  def github_commands
    c = Travis::Config.new(project.path + "/.travis.yml")
    script = "#{project.path}/.ci_runner"
    File.open(script, "w") do |io|
      io.write c.to_runnable
    end
    ["/bin/bash #{script}"]
  end
end
