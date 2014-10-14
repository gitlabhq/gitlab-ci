class CreateBuildService
  class Shell
    def execute(project, data)
      ActiveRecord::Base.transaction do
        begin
          build_group_data = data.dup
          build_group_data.delete(:build_method)
          build_group = project.build_groups.create(build_group_data)

          data.merge!(labels: build_labels(project))
          data.merge!(build_group_id: build_group.id)
          data.merge!(build_attributes: nil)
          data.merge!(matrix_attributes: nil)
          project.builds.create(data)

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

    def build_labels(project)
      project.labels.delete(" ").split(",") || 'shell linux'
    end
  end
end
