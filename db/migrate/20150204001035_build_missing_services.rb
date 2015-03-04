class BuildMissingServices < ActiveRecord::Migration
  def up
    Project.find_each do |project|
      project.build_missing_services if project.respond_to?(:build_missing_services)
    end
  end
end
