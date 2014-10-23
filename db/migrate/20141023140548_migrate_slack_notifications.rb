class MigrateSlackNotifications < ActiveRecord::Migration
  def change
    Project.where.not(slack_notification_subdomain: nil, slack_notification_token: nil).each do |project|
      if project.slack_notification_subdomain.present? and project.slack_notification_token.present?
        webhook_url = "https://#{project.slack_notification_subdomain}.slack.com/services/hooks/incoming-webhook?token=#{project.slack_notification_token}"
        project.update_attributes(slack_notification_webhook: webhook_url)
      end
    end
  end
end
