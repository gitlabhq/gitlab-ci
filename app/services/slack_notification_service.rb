# SlackNotificationService class
#
# Used for notifying users with on slack about different events
#
# Ex.
#   SlackNotificationService.new.build_ended(build)
#
require 'slack_notifier'

class SlackNotificationService
  def build_started(build)
    return unless build.build_group
    return unless build.build_group.builds.where.not(started_at: nil).empty?
    Slack::Notifier.build_started_slack_post(build)
  end

  def build_ended(build)
    return unless build.build_group
    case build.build_group.status.to_sym
    when :success
      Slack::Notifier.build_success_slack_post(build)
    when :failed
      Slack::Notifier.build_fail_slack_post(build)
    end
  end

end
