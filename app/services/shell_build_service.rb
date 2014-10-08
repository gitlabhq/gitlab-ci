class CreateBuildService
  class Shell
    def execute(project, data)
      build_group_data = data.dup
      build_group_data.delete(:build_method)
      build_group = project.build_groups.create(build_group_data)

      data[:labels] = project.labels.delete(" ").split(",")
      data[:build_group_id] = build_group.id
      project.builds.create(data)

      # return build group
      build_group
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

    def build_end(build)
    end
  end
end
