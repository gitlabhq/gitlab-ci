class CreateBuildService
  class Shell
    def execute(project, data)
      data[:labels] = project.labels.delete(" ").split(",")
      project.builds.create(data)
    end

    def detected?(project)
      true
    end

    def build_commands(build)
      build.project.scripts
    end

    def format_build_attributes(build)
      nil
    end

    def format_matrix_attributes(build)
      nil
    end
  end
end
