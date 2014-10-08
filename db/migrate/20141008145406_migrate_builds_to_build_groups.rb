class MigrateBuildsToBuildGroups < ActiveRecord::Migration
  def change
    reversible do |migration|
      migration.up do
        Build.where(build_group_id: nil).pluck(:sha).uniq do |sha|
          all_builds = Build.where(sha: sha).where(build_group_id: nil)
          latest_build = all_builds.order('created_at desc').last
          next unless latest_build

          build_group = Build.create(
              sha: latest_build.sha,
              before_sha: latest_build.before_sha,
              push_data: latest_build.push_data,
              ref: latest_build.ref,
              ref_type: latest_build.ref_type,
              project_id: latest_build.project.id
          )

          all_builds.update_all(build_group_id: build_group.id)
        end
      end
      migration.down
    end
  end
end
