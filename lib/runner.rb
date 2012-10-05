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
    commands.each_line do |line|
      line = line.strip
      trace << "\n"
      cmd = "cd #{path} && " + line
      trace << cmd
      trace << "\n"
      trace << `#{cmd}`

      unless $?.exitstatus == 0
        build.update_attributes(
          trace: trace,
          status: 'fail'
        )

        return false
      end
    end

    build.update_attributes(
      trace: trace,
      status: 'success'
    )
  end
end
