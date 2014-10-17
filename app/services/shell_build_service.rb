class CreateBuildService
  class Shell
    def execute(project, data)
      ActiveRecord::Base.transaction do
        begin
          build_group_data = data.dup
          build_group_data.delete(:build_method)
          build_group = project.build_groups.create(build_group_data)

          build_data = build_group_data.dup
          build_data.merge!(build_os: project.build_os)
          build_data.merge!(build_image: project.build_image)
          build_data.merge!(build_group_id: build_group.id)
          build_data.merge!(build_attributes: nil)
          project.builds.create(build_data)

          # return build group
          build_group
        rescue
          raise ActiveRecord::Rollback
        end
      end
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
