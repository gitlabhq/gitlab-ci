class AddSlackNotificationToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :slack_notification_webhook, :string
  end
end
