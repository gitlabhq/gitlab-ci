class Runner
  attr_accessor :project, :build

  def initialize(project)
    @project = project
  end

  def run
    @build = Build.create(
      project_id: project.id,
      status: 'undefined'
    )

    trace = ''
    path = project.path
    project.scripts.each_line do |line|
      cmd = "cd #{path} && " + line
      trace << `#{cmd}`

      unless $?.exitstatus == 0
        @build.update_attributes(
          trace: trace,
          status: 'fail'
        )

        return false
      end
    end

    @build.update_attributes(
      trace: trace,
      status: 'success'
    )
  end
end
