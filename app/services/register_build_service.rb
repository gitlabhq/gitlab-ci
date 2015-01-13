# This class responsible for assigning
# proper pending build to runner on runner API request
class RegisterBuildService
  def execute(current_runner)
    builds = Build.pending.unstarted

    builds =
      if current_runner.shared?
        # don't run projects which are assigned to specific runners
        projects = RunnerProject.pluck(:project_id)
        builds.where.not(project_id: projects)
      else
        # do run projects which are only assigned to this runner
        builds.where(project_id: current_runner.projects)
      end

    builds = builds.order('created_at ASC')

    build =
      if current_runner.tag_list.present?
        builds.find do |build|
          (build.tag_list - current_runner.tag_list).empty?
        end
      else
        builds.first
      end

    if build
      ActiveRecord::Base.transaction do
        build.runner_id = current_runner.id
        build.save!
        build.run!
      end
    end

    build
  end
end
