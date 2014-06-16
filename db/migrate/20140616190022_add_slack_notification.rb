class AddSlackNotification < ActiveRecord::Migration
  def change
    add_column :projects, :slack_only_broken_builds,     :boolean
    add_column :projects, :slack_notification_channel,   :string, limit: 16
    add_column :projects, :slack_notification_subdomain, :string, limit: 16
    add_column :projects, :slack_notification_token,     :string, limit: 32
    add_column :projects, :slack_notification_username,  :string, limit: 16
  end
end
