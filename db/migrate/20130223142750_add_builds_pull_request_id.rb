class AddBuildsPullRequestId < ActiveRecord::Migration
  def change
    add_column :builds, :pull_request_number, :string
  end
end
