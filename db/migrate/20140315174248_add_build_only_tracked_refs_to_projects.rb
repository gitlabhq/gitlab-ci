class AddBuildOnlyTrackedRefsToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :build_only_tracked_refs, :boolean, null: false, default: false
  end
end
