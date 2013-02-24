class AddBuildsPullRequestRef < ActiveRecord::Migration
  def change
    add_column :builds, :pull_request_ref, :string
  end
end
